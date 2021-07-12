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
    
    private
    let allowWarnings: Bool
    
    internal
    init?(_ file: File, _ allowWarnings: Bool) {
        self.file = file
        self.allowWarnings = allowWarnings
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
        var targets = names.compactMap{ Target($0, self.file.workDirectory)}
        if targets.count != names.count {
            Log.println("Cant't create all required targets", .failure)
            return false
        }
        
        guard self.validateTargets(targets)
        else { return false }
        
        let prepareUnreleasedTarget = self.prepareUnreleasedTarget(targets)
        guard prepareUnreleasedTarget.0
        else { return false }
        
        targets = prepareUnreleasedTarget.1
        guard targets.count > 0 else {
            Log.println("Nothing to release !!!", .info)
            return true
        }
        
        return self.releaseUnreleasedTargets(targets)
    }
}

private
extension ReleaseTool {
    
    @discardableResult
    func validateTargets(_ targets: [Target]) -> Bool {
        return
            self.checkSpecsSource(targets) &&
            self.checkAvailableSpecVersion(targets)
    }
    
    @discardableResult
    func prepareUnreleasedTarget(_ targets: [Target]) -> (Bool, [Target]) {
        Log.println("Start prepare unreleased target", .info)
        var unreleasedTarget: [Target] = []
        let result = targets.reduce(true) {
            guard let version = $1.spec.tagName
            else {
                Log.println("Spec \($1.spec.name) git version not available", .failure)
                return $0 && false
            }
            
            let isReleased = $1.gitContainsTargetVersion(version)
            if isReleased {
                Log.println("Spec \($1.spec.name) git version \(version) allready released", .warning)
            } else {
                unreleasedTarget.append($1)
            }
            
            return $0 && (self.allowWarnings || !isReleased)
        }
        Log.println("Finish prepare unreleased target", result ? .success : .failure)
        return (result, unreleasedTarget)
    }
    
    @discardableResult
    func releaseUnreleasedTargets(_ targets: [Target]) -> Bool {
        Log.println("Start release unreleased targets:", .info)
        Log.println("\(targets.compactMap { $0.spec.name })", .info)
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
    
    @discardableResult
    func checkAvailableSpecVersion(_ targets: [Target]) -> Bool {
        Log.println("Start check available specs version", .info)
        let result = targets.reduce(true) {
            guard let version = $1.spec.specVersion
            else {
                Log.println("Spec \($1.spec.name) version not available", .failure)
                return $0 && false
            }
            Log.println("Spec \($1.spec.name) version: \(version)", .verbose)
            return $0 && true
        }
        Log.println("Finish check available specs version", result ? .success : .failure)
        return result
    }
}


