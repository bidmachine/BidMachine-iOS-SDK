//
//  File.swift
//
//
//  Created by Ilia Lozhkin on 31.05.2021.
//

import Foundation

internal
class Target {
    
    private static
    let targetRootPath = "BidMachineRelease"
    
    private static
    let gitAdaptersDir = "BidMachine-iOS-Adaptors"
    
    internal
    enum Dir: String {
        case release
        
        internal
        var path: String {
            switch self {
            case .release: return File.path(with: Target.targetRootPath, "Releases")
            }
        }
    }
    
    internal
    enum Name: String {
        case BidMachine
        case StackAPI
        case BDMAdColonyAdapter
        case BDMAmazonAdapter
        case BDMAppRollAdapter
        case BDMCriteoAdapter
        case BDMFacebookAdapter
        case BDMMyTargetAdapter
        case BDMSmaatoAdapter
        case BDMTapjoyAdapter
        case BDMVungleAdapter
        case BDMMRAIDAdapter
        case BDMVASTAdapter
        case BDMNASTAdapter
        case BDMIABAdapter
        
        internal
        var isFramework: Bool {
            let frameworkNames: [Target.Name] = [.BidMachine, .StackAPI]
            return frameworkNames.contains(self)
        }
    }
    
    internal
    let framework: Framework

    internal
    let spec: Spec

    internal
    let git: Git

    internal
    let file: File

    internal
    init?(_ name: Name, _ rootPath: String) {

        let path = File.path(with: rootPath, Self.targetRootPath)
        
        guard
            let file = File(path),
            let framework = Framework(name, file.workDirectory),
            let spec = Spec(name, file.workDirectory),
            let gitFile = name.isFramework ? Git(absolute: rootPath) : Git(absolute: File.path(with: rootPath, Self.gitAdaptersDir))
        else {
            Log.println("Can't create Target: \(name.rawValue)", .failure)
            return nil
        }

        self.framework = framework
        self.spec = spec
        self.git = gitFile
        self.file = file
    }
    
}

internal
extension Target {
    
    static
    func frameworkDir(_ dir: Framework.Dir) -> String {
        return File.path(with: targetRootPath, dir.path)
    }

}

internal
extension Target {
    
    func gitContainsTargetVersion(_ version: String) -> Bool {
        return self.git.existTag(version)
    }
    
}
