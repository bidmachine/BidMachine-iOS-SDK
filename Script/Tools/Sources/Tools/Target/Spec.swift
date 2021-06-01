//
//  File.swift
//  
//
//  Created by Ilia Lozhkin on 31.05.2021.
//

import Foundation

internal
class Spec {
    
    private static
    let specRootPath = "Specs"
    
    internal
    enum Dir: String {
        
        case license
        case podspec
        case changelog
    }

    internal
    let isAdapter: Bool
    
    private
    let rootPath: String
    
    private
    let targetName: Target.Name
    
    init(_ name: Target.Name, _ rootPath: String) {
        self.rootPath = rootPath
        self.targetName = name
        self.isAdapter = name != .BidMachine
    }
}

internal
extension Spec {
    
    var name: String {
        return self.targetName.rawValue
    }
    
    func path(_ dir: Dir) -> String {
        var subPath = ""
        switch dir {
        case .license: subPath = "LICENSE"
        case .changelog: subPath = "CHANGELOG.md"
        case .podspec: subPath = "\(self.name).podspec"
        }
        
        return File.path(with: self.rootPath, Spec.specRootPath, subPath)
    }
}
