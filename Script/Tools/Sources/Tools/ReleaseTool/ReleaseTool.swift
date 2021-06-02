//
//  ReleaseTool.swift
//
//
//  Created by Ilia Lozhkin on 28.05.2021.
//

import Foundation


internal
class ReleaseTool {
    
    private
    struct Config {
        static let targets: [Target.Name] =
            [
                .BidMachine,
                .BDMAdColonyAdapter,
                .BDMAmazonAdapter,
                .BDMAppRollAdapter,
                .BDMCriteoAdapter,
                .BDMFacebookAdapter,
                .BDMMyTargetAdapter,
                .BDMSmaatoAdapter,
                .BDMTapjoyAdapter,
                .BDMVungleAdapter,
                .BDMIABAdapter
            ]
    }
    
    private
    let file: File
    
    internal
    init?(_ file: File, _ allowWarnings: Bool) {
        self.file = file
    }
    
    @discardableResult internal
    func release(_ type: [String]) -> Bool {
        var targetNames: [Target.Name] = []
        if type.contains("All") {
            targetNames = Config.targets
        } else {
            var targetNames = type.compactMap { Target.Name(rawValue: $0) }
            if type.contains("Adapters") {
                targetNames = targetNames.filter{ $0.isFramework }
                targetNames = targetNames + Config.targets.filter { !$0.isFramework }
            }

            if type.contains("Sdk") {
                targetNames = targetNames.filter{ !$0.isFramework }
                targetNames = targetNames + Config.targets.filter { $0.isFramework }
            }
        }
        
        Log.println("Start release targets!", .info)
        Log.println("\(targetNames.compactMap { $0.rawValue })", .info)
        let result = self._release(targetNames)
        Log.println("Finish release targets!", result ? .success : .failure)

        return result
    }
}

private
extension ReleaseTool {
    
    @discardableResult
    func _release(_ names: [Target.Name]) -> Bool {
        let targets = names.compactMap{ Target($0, self.file.workDirectory)}
        if targets.count != names.count {
            Log.println("Cant't create all required targets", .failure)
            return false
        }
        
        return
            self.validateTargets(targets)
    }
}

private
extension ReleaseTool {
    
    @discardableResult
    func validateTargets(_ targets: [Target]) -> Bool {
        return
            self.checkSpecsSource(targets)
    }
    
    @discardableResult
    func prepareTargets(_ targets: [Target]) -> Bool {
        return true
    }
}

private
extension ReleaseTool {
    
    @discardableResult
    func checkSpecsSource(_ targets: [Target]) -> Bool {
        Log.println("Start check available specs sources", .info)
        let result = targets.reduce(true) { $0 && $1.spec.validateResources() }
        Log.println("Finish check available specs sources", result ? .success : .failure)
        return result
    }
}


