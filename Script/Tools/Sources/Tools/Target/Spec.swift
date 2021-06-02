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
    let name: String
    
    internal
    var isAdapter: Bool {
        !self.targetName.isFramework
    }
    
    internal lazy
    var specVersion: String? = {
        self._specVersion()
    }()
    
    internal lazy
    var tagName: String? = {
        self._tagName()
    }()
    
    private
    let targetName: Target.Name
    
    private
    let file: File
    
    init?(_ name: Target.Name, _ rootPath: String) {
        self.name = name.rawValue
        
        let path = File.path(with: rootPath, Self.specRootPath)
        guard let file = File(path) else {
            Log.println("Can't create Spec: \(name). Root path not found: \(path)", .failure)
            return nil
        }
        
        self.file = file
        self.targetName = name
    }
}

private
extension Spec {
    
    func _path(_ dir: Dir) -> String {
        var filePath = ""
        switch dir {
        case .license: filePath = "LICENSE"
        case .changelog: filePath = "CHANGELOG.md"
        case .podspec: filePath = "\(self.name).podspec"
        }
        
        return File.path(with: self.name, filePath)
    }
}

private
extension Spec {
    
    func _specVersion() -> String? {
        guard let text = try? String(contentsOfFile: self.file.path(self._path(.podspec)), encoding: .utf8) else {
            return nil
        }
        
        let sdkPattern = #".*(sdkVersion\s*.*=(.*\"(.*).*\"))"#
        let adapterPattern = #".*(adapterVersion\s*.*=(.*\"(.*).*\"))"#
        let pattern = self.targetName.isFramework ? sdkPattern : adapterPattern
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
    
    func _tagName() -> String? {
        guard let version = self.specVersion else {
            return nil
        }
        return self.targetName.isFramework ? "v\(version)" : "v\(self.name)-\(version)"
    }
}

internal
extension Spec {
    
    func validateResources() -> Bool {
        let changelogPath = self.file.path(self._path(.changelog))
        let licensePath = self.file.path(self._path(.license))
        let specPath = self.file.path(self._path(.podspec))
        
        let checkResult =
            Log.completionLog(File.exist(changelogPath), "Exist file path: \(changelogPath)", .verbose) &&
            Log.completionLog(File.exist(licensePath), "Exist file path: \(licensePath)", .verbose) &&
            Log.completionLog(File.exist(specPath), "Exist file path: \(specPath)", .verbose)
        
        Log.println("Check spec: \(self.name) source", checkResult ? .verbose : .failure)
        return checkResult
    }
    
}
