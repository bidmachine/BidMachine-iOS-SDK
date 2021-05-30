//
//  File.swift
//  
//
//  Created by Ilia Lozhkin on 29.05.2021.
//

import Foundation

public
enum Spec {
    
    internal
    enum PathType {
        case license
        case podspec
        case changelog
    }
    
    case spec(Framework)
    
    internal
    var name: String {
        switch self {
        case .spec(let framework): return framework.rawValue
        }
    }
    
    internal
    func path(_ type: PathType) -> String {
        
        switch self {
        case .spec(let framework):
            var subPath = ""
            switch type {
            case .license: subPath = "\(framework.rawValue)/LICENSE"
            case .podspec: subPath = "\(framework.rawValue).podspec"
            case .changelog: subPath = "\(framework.rawValue)/CHANGELOG.md"
            }
            return "\(framework.rawValue)/\(subPath)"
        }
    }
}
