//
//  File.swift
//  
//
//  Created by Ilia Lozhkin on 29.05.2021.
//

import Foundation

public
struct SpecProcess {
    
    let rootPath: String
    let releasesPath: String
    let frameworksPath: String
    let allowWarnings: Bool
    
    public
    init(_ specRootPath: String, _ releasesPath: String, _ frameworksPath: String, _ allowWarnings: Bool) {
        self.rootPath = specRootPath
        self.releasesPath = releasesPath
        self.frameworksPath = frameworksPath
        self.allowWarnings = allowWarnings
    }
}

public
extension SpecProcess {
    
    @discardableResult
    func execute(_ spec: Spec) -> Bool {
        return self.validateSpecSources(spec)
    }
}

private
extension SpecProcess {
    
    @discardableResult
    func validateSpecSources(_ spec: Spec) -> Bool {
        Log.println("Start validate spec: \(spec.name)", .info)
        
        let components: [Spec.PathType] = [.changelog, .license, .podspec]
        let result = components.reduce(true) {
            let path = File.path(with: rootPath,spec.path($1))
            let result = File.exist(path)
            if !result {
                Log.println("Can't find required spec component at path: \(path)", .failure)
            }
            return $0 && result
        }
        Log.println("Fininsh validate spec", result ? .success : .failure)
        return result
    }
    
    @discardableResult
    func parseSpecVersion(_ spec: Spec) -> Bool {
        
    }
}
