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
        return true
    }
}
