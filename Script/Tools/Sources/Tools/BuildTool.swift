import Foundation

public
class Build {
     
    private let file = File()
    
    public
    func build() -> Bool {
        Router.shared.print("Start build sdk!", .success)
        
        let path = self.file.filePath(Paths.workspace)
        guard
            let workSpacePath = path,
            self.file.fileExist(Paths.workspace)
        else {
            Router.shared.print("Workspace \(String(describing: path)) not found", .failure)
            return false
        }
        
        Router.shared.print("--- Workspace: \(workSpacePath)", .info)
        Router.shared.print("--- Scheme: \(Scheme.release)", .info)
        
        return
            self.prepareBuildDirectory() &&
            self.buildFrameworks(workSpacePath) &&
            self.prepareLibDirectory() &&
            self.copyRequiredFrameworks() &&
            self.makeUniversalLibs() &&
            self.mergeFrameworks() &&
            self.cleanMergingDependencies() &&
            self.copyFiles() &&
            self.cleanBuildDirectory()
    }
    
}

private
extension Build {
    
    func buildFrameworks(_ path: String) -> Bool {
        var result = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let xcbuild = XCBuild(path, Scheme.release)
            result = xcbuild.build()
            group.leave()
        }
        
        group.wait()
        return result
    }
}

private
extension Build {
    
    @discardableResult
    func prepareBuildDirectory() -> Bool {
        self.file.removeFile(Paths.build)
        self.file.removeFile(Paths.frameworks)
        self.file.createFile("\(Paths.build)/\(BuildType.iphoneos.rawValue)")
        self.file.createFile("\(Paths.build)/\(BuildType.iphonesimulator.rawValue)")
        return true
    }
    
    @discardableResult
    func prepareLibDirectory() -> Bool {
        self.file.removeFile("\(Paths.build)/\(BuildType.universal)")
        self.file.createFile("\(Paths.build)/\(BuildType.universal)")
        return true
    }
    
    @discardableResult
    func cleanMergingDependencies() -> Bool {
        mergingMap
            .reduce(into: [String]()) { result, item in
                result.append(contentsOf: item.value.compactMap {
                    if (item.key != $0) {
                        return $0.pathToLib(.universal)
                    }
                    return nil
                })
            }
            .forEach { self.file.removeFile($0)}
        return true
    }
    
    @discardableResult
    func copyFiles() -> Bool {
        self.file.removeFile(Paths.frameworks)
        self.file.createFile(Paths.frameworks)
        self.file.copyFiles("\(Paths.build)/\(BuildType.universal)", Paths.frameworks)
        return true
    }
    
    @discardableResult
    func cleanBuildDirectory() -> Bool {
        self.file.removeFile(Paths.build)
        return true
    }
}

private
extension Build {
    
    func copyRequiredFrameworks() -> Bool {
        return requiredFrameworks.reduce(true) { $0 && self.copyRequiredFramework($1) }
    }
    
    func copyRequiredFramework(_ framework: Frameworks) -> Bool {
        let fromPath = framework.pathToLib(.iphoneos)
        let toPath = framework.pathToLib(.universal)
        
        self.file.copy(fromPath, toPath)
        self.file.removeFile(toPath.flatMap { $0 + "/PrivateHeaders"})
        self.file.removeFile(toPath.flatMap { $0 + "/\(framework.rawValue)"})
        
        if self.file.fileExist(toPath) {
            return true
        } else {
            Router.shared.print("Can't create reqired framework path: \(String(describing: toPath))", .failure)
            return false
        }
    }
}

private
extension Build {
    func makeUniversalLibs() -> Bool {
        return (requiredFrameworks + requiredLibs).reduce(true) { $0 && self.makeUniversalLib($1) }
    }
    
    func makeUniversalLib(_ framework: Frameworks) -> Bool {
        guard
            let simulatorPath = self.file.filePath(framework.pathToBin(.iphonesimulator)),
            let iphonePath = self.file.filePath(framework.pathToBin(.iphoneos)),
            let universalPath = self.file.filePath(framework.pathToBin(.universal))
        else {
            Router.shared.print("Create universal lib for: \(framework.rawValue), file not found", .failure)
            return false
        }
        
        let result = Lib.lipo(universalPath, simulatorPath, iphonePath)
        Router.shared.print("Create universal lib for: \(framework.rawValue)", result ? .success : .failure)
        return result
    }
}

private
extension Build {
    func mergeFrameworks() -> Bool {
        return mergingMap.reduce(true) { $0 && self.mergeFramework($1.key, $1.value) }
    }
    
    func mergeFramework(_ framework: Frameworks, _ dependencies: [Frameworks]) -> Bool {
        let paths: [String] = dependencies.compactMap { self.file.filePath($0.pathToBin(.universal)) }
        guard paths.count == dependencies.count else {
            Router.shared.print("Create fat framework: \(framework.rawValue), dependecies not found", .failure)
            return false
        }
        
        guard let universalPath = self.file.filePath(framework.pathToBin(.universal)) else {
            Router.shared.print("Create fat framework: \(framework.rawValue), file not found", .failure)
            return false
        }
        let result = Lib.libtool(universalPath, paths)
        Router.shared.print("Create fat framework for: \(framework.rawValue)", result ? .success : .failure)
        return result
    }
}

private
extension Frameworks {
    func pathToLib(_ type: BuildType) -> String? {
        if requiredFrameworks.contains(self) {
            return  "\(Paths.build)/\(type.rawValue)/\(self.rawValue).framework"
        }
        return "\(Paths.build)/\(type.rawValue)/lib\(self.rawValue).a"
    }
    
    func pathToBin(_ type: BuildType) -> String? {
        if requiredFrameworks.contains(self) {
            return self.pathToLib(type).flatMap{ $0 + "/" + self.rawValue}
        }
        return self.pathToLib(type)
    }
}
