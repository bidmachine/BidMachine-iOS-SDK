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
    let isFramework: Bool
    
    private
    let rootPath: String
    
    private
    let targetName: Target.Name
    
    internal
    init(_ name: Target.Name, _ rootPath: String) {
        let frameworkNames: [Target.Name] = [.BidMachine, .StackAPI]
        self.targetName = name
        self.rootPath = rootPath
        self.isFramework = frameworkNames.contains(name)
        
    }
    
}

internal
extension Framework {
    
    var name: String {
        if self.isFramework {
            return "\(self.targetName.rawValue).framework"
        } else {
            return "lib\(self.targetName.rawValue).a"
        }
    }
    
    func path(_ dir: Dir) -> String {
        return File.path(with: self.rootPath, dir.path, self.name)
    }
    
    func binPath(_ dir: Dir) -> String {
        return self.isFramework ? File.path(with: self.path(dir), self.targetName.rawValue) : self.path(dir)
    }
}
