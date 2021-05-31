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
    
    func dirPath(_ dir: Dir) -> String {
        return File.path(with:self.rootPath, dir.path)
    }
    
    func path(_ dir: Dir) -> String {
        return File.path(with: self.dirPath(dir), self.name)
    }
    
    func binPath(_ dir: Dir) -> String {
        return self.isFramework ? File.path(with: self.path(dir), self.targetName.rawValue) : self.path(dir)
    }
}

//public
//enum Framework: String {
//
//    internal
//    enum LibType {
//        case framework
//        case lib
//    }
//
//    case BidMachine
//    case StackAPI
//    case BDMAdColonyAdapter
//    case BDMAmazonAdapter
//    case BDMAppRollAdapter
//    case BDMCriteoAdapter
//    case BDMFacebookAdapter
//    case BDMMyTargetAdapter
//    case BDMSmaatoAdapter
//    case BDMTapjoyAdapter
//    case BDMVungleAdapter
//    case BDMMRAIDAdapter
//    case BDMVASTAdapter
//    case BDMNASTAdapter
//    case BDMIABAdapter
//
//    internal var type: LibType {
//        let frameworks: [Framework] = [.BidMachine, .StackAPI]
//        return frameworks.contains(self) ? .framework : .lib
//    }
//
//    internal
//    var binPath: String {
//        switch self.type {
//        case .framework: return "\(self.rawValue).framework/\(self.rawValue)"
//        case .lib: return "lib\(self.rawValue).a"
//        }
//    }
//
//    internal
//    var path: String {
//        switch self.type {
//        case .framework: return "\(self.rawValue).framework"
//        case .lib: return "lib\(self.rawValue).a"
//        }
//    }
//
//    public
//    var description: String {
//        return self.path
//    }
//}
