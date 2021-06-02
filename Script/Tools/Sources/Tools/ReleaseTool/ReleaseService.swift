//
//  File.swift
//  
//
//  Created by Ilia Lozhkin on 01.06.2021.
//

import Foundation

internal protocol
ReleaseServiceProtocol {
    
    init(_ file: File, _ git: Git, _ allowWarnings: Bool)
    
    var targets: [Target]? { get set}
    
    @discardableResult
    func release() -> Bool
}

internal
class ReleaseService : ReleaseServiceProtocol {
    
    var targets: [Target]?
    
    private
    let file: File
    
    private
    let git: Git
    
    private
    let allowWarnings: Bool
    
    required init(_ file: File, _ git: Git, _ allowWarnings: Bool) {
        self.file = file
        self.git = git
        self.allowWarnings = allowWarnings
    }
    
    @discardableResult
    func release() -> Bool {
        guard
            let targets = self.targets,
            targets.count > 0
        else {
            return true
        }
        
        Log.println("Start release targets: \(targets.compactMap { $0.spec.name })", .info)
        
        let result = self.specVersions(targets)
//            self.checkAvailableSpecSources(targets) &&
//            self.checkAvailableFrameworkSources(targets)
        
        Log.println("Finish release", result ? .success : .failure)
        
        return result
    }
}

private
extension ReleaseService {
}

private
extension ReleaseService {
    
    func checkAvailableSpecSources(_ targets: [Target]) -> Bool {
        Log.println("Start check available specs sources", .info)
        
        let result = targets.reduce(true) { result, target in
            Log.println("For spec: \(target.spec.name)", .verbose)
            
            let changelogPath = self.file.path(target.spec.path(.changelog))
            let licensePath = self.file.path(target.spec.path(.license))
            let specPath = self.file.path(target.spec.path(.podspec))
            

            let checkResult =
                Log.completionLog(File.exist(changelogPath), "Exist file path: \(changelogPath)", .verbose) &&
                Log.completionLog(File.exist(licensePath), "Exist file path: \(licensePath)", .verbose) &&
                Log.completionLog(File.exist(specPath), "Exist file path: \(specPath)", .verbose)
            
            Log.println("Check spec: \(target.spec.name) source", checkResult ? .verbose : .failure)
            
            return result && checkResult
        }
        Log.println("Finish check available specs sources", result ? .success : .failure)
        return result
    }
    
    func checkAvailableFrameworkSources(_ targets: [Target]) -> Bool {
        Log.println("Start check available frameworks sources", .info)
        
        let result = targets.reduce(true) { result, target in
            Log.println("For spec: \(target.spec.name)", .verbose)
            
            let frameworkPath = self.file.path(target.framework.path(.universal))
            let checkResult = Log.completionLog(File.exist(frameworkPath), "Exist file path: \(frameworkPath)", .verbose)
            
            Log.println("Check spec: \(target.spec.name) framework source", checkResult ? .verbose : .failure)
            
            return result && checkResult
        }
        
        Log.println("Finish check available frameworks sources", result ? .success : .failure)
        return result
    }
}

private
extension ReleaseService {
    
    func specVersions(_ targets: [Target]) -> Bool {
        let result = targets.reduce(true) { result, target in
            guard let specVersion = target.spec.tagName(self.file.projectDirectory) else {
                Log.println("Spec \(target.spec.name) not contain version ", .failure)
                return false
            }
            Log.println("Spec \(target.spec.name) - \(specVersion)", .success)
            let gitResult = git.existTag(specVersion)
            Log.println("Git tag exist: \(specVersion)", gitResult ? .success : .failure)
            return result && gitResult
        }
        return result
    }
}
