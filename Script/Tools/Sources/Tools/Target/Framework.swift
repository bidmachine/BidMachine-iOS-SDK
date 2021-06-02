//
//  File.swift
//
//
//  Created by Ilia Lozhkin on 31.05.2021.
//

import Foundation

internal
class Framework {
    
    internal
    enum Dir: String {
        
        case iphoneos
        case iphonesimulator
        case universal
        
        internal
        var path: String {
            return self.rawValue
        }
    }
    
    internal
    let name: String
    
    internal
    var isFramework: Bool {
        self.targetName.isFramework
    }
    
    private
    let targetName: Target.Name
    
    private
    let file: File
    
    internal
    init?(_ name: Target.Name, _ rootPath: String) {
        self.name = Self._name(name)
        
        let path = File.path(with: rootPath)
        guard let file = File(path) else {
            Log.println("Can't create Framework: \(self.name). Root path not found: \(path)", .failure)
            return nil
        }
        
        self.file = file
        self.targetName = name
    }
}

private
extension Framework {
    
    static
    func _name(_ name: Target.Name) -> String {
        if name.isFramework {
            return "\(name.rawValue).framework"
        } else {
            return "lib\(name.rawValue).a"
        }
    }
    
    func _path(_ dir: Dir, _ bin: Bool = false) -> String {
        var path = File.path(with: dir.path, self.name)
        if bin && self.isFramework{
            path = File.path(with: path, self.targetName.rawValue)
        }
        return path
    }
}

internal
extension Framework {
    
    @discardableResult
    func copy() -> Bool {
        let path = self.file.path(self._path(.iphoneos))
        guard File.exist(path) else {
            Log.println("Framework not exist at path: \(path)", .failure)
            return false
        }

        return
            self.file.copy(self._path(.iphoneos), self._path(.universal)) &&
            self.file.remove(self._path(.universal), "PrivateHeaders") &&
            self.file.remove(self._path(.universal, true))
    }

    @discardableResult
    func createUniversal() -> Bool {
        Log.println("Try create universal lib for: \(self.name)", .info)
        let iphonePath = self.file.path(self._path(.iphoneos, true))
        let simulatorPath = self.file.path(self._path(.iphonesimulator, true))
        let universalPath = self.file.path(self._path(.universal, true))

        guard File.exist(iphonePath) else {
            Log.println("Framework: \(self.name) not contain required iphone lib for path: \(iphonePath)", .failure)
            return false
        }

        guard File.exist(simulatorPath) else {
            Log.println("Framework: \(self.name) not contain required simulator lib for path: \(simulatorPath)", .failure)
            return false
        }

        let result =
            self.file.create(Dir.universal.path) &&
            Lib.lipo(universalPath, simulatorPath, iphonePath)

        Log.println("Create universal lib for: \(self.name)", result ? .success : .failure)
        return result
    }

    @discardableResult
    func createFat(_ submodule: [Framework], _ removeSubmodule: Bool) -> Bool {
        Log.println("Try create fat lib for: \(self.name)", .info)
        Log.println("-- Components: \(submodule.compactMap { $0.name }.joined(separator: ", "))", .info)

        let exists: Bool = submodule.reduce(true) {
            let exist = self.file.exist($1._path(.universal, true))
            if !exist {
                Log.println("-- Not found fat framework component: \($1.name)", .failure)
            }
            return $0 && exist
        }
        guard exists else {
            Log.println("Can't create fat lib for: \(self.name)", .failure)
            return false
        }

        let result =
            Lib.libtool(self.file.path(self._path(.universal, true)), submodule.compactMap{ self.file.path($0._path(.universal, true))}) &&
            (removeSubmodule ? self.removeSubmodule(submodule) : true)

        Log.println("Create fat lib for: \(self.name)", result ? .success : .failure)
        return result
    }

    @discardableResult private
    func removeSubmodule(_ submodule: [Framework]) -> Bool {
        submodule.forEach {
            if ($0.name != self.name) {
                self.file.remove($0._path(.universal))
            }
        }
        return true
    }
}
