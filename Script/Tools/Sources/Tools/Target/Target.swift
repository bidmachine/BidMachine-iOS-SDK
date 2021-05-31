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
    let releaseRootPath = "BidMachineRelease"
    
    internal
    enum Dir: String {
        case release
        
        internal
        var path: String {
            switch self {
            case .release: return File.path(with: Target.releaseRootPath, "Releases")
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
    }
    
    internal
    let framework: Framework
    
    internal
    let spec: Spec
    
    internal
    init(_ name: Name) {
        self.framework = Framework(name, Target.releaseRootPath)
        self.spec = Spec(self.framework)
    }
    
}

internal
extension Target {
    
    static
    func frameworkDir(_ dir: Framework.Dir) -> String {
        return File.path(with: releaseRootPath, dir.path)
    }
}
