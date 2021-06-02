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
        
        return File.path(with: self.rootPath, Spec.specRootPath, self.name, subPath)
    }
}

internal
extension Spec {
    
    func specVersion(_ path: String) -> String? {
        guard let text = try? String(contentsOfFile: File.path(with: path, self.path(.podspec)), encoding: .utf8) else {
            return nil
        }
        
        let sdkPattern = #".*(sdkVersion\s*.*=(.*\"(.*).*\"))"#
        let adapterPattern = #".*(adapterVersion\s*.*=(.*\"(.*).*\"))"#
        let pattern = self.isAdapter ? adapterPattern : sdkPattern
        let regex = try! NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
        
        
        let stringRange = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, range: stringRange)
        var result: [[String]] = []
        for match in matches {
            var groups: [String] = []
            for rangeIndex in 1 ..< match.numberOfRanges {
                groups.append((text as NSString).substring(with: match.range(at: rangeIndex)))
            }
            if !groups.isEmpty {
                result.append(groups)
            }
        }
        
        return result.last.flatMap { $0.last }
    }
    
}
