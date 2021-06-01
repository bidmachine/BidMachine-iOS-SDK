import Foundation

public
class File {
    
    internal
    let projectDirectory: String
    
    public
    init?(_ projectDirectory: String?) {
        let projectDirectory = projectDirectory ??
            URL(string: FileManager.default.currentDirectoryPath).flatMap ({ $0.deletingLastPathComponent() }).flatMap ({ $0.absoluteString })
        guard
            let dir = projectDirectory,
            File.exist(dir)
        else {
            Log.println("Can't find project dir at path: \(String(describing: projectDirectory))", .failure)
            return nil
        }
        
        self.projectDirectory = dir
    }
}

public
extension File {
    
    static
    func path(with components: String...) -> String {
        return self.path(with: components)
    }
    
    static
    func path(with components: [String]) -> String {
        return components.joined(separator: "/").replacingOccurrences(of: "//", with: "/")
    }
    
    @discardableResult static
    func exist(_ absolutePath: String) -> Bool {
        guard FileManager.default.fileExists(atPath: absolutePath) else {
            return false
        }
        return true
    }
    
    @discardableResult static
    func copy(_ fromAbsolutePath: String, _ toAbsolutePath: String) -> Bool {
        Log.println("- Try copy file \n-- From: \(fromAbsolutePath) \n-- To: \(toAbsolutePath)", .verbose)
        guard self.exist(fromAbsolutePath) else {
            Log.println("Non existent copying file at path: \(fromAbsolutePath)", .failure)
            return false
        }
        
        guard
            let result = URL(string: toAbsolutePath)
                .flatMap({ $0.deletingLastPathComponent()})
                .flatMap ({ $0.absoluteString })
                .flatMap({ self.create($0) }),
            result == true
        else {
            Log.println("Root file not exist for direct path: \(toAbsolutePath)", .failure)
            return false
        }
        
        guard !self.exist(toAbsolutePath) else {
            Log.println("Copy target allready contain same file at path: \(toAbsolutePath)", .failure)
            return false
        }
        
        do {
            try FileManager.default.copyItem(atPath: fromAbsolutePath, toPath: toAbsolutePath)
            Log.println("-- Complete copy files", .verbose)
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult static
    func create(_ absolutePath: String) -> Bool {
        Log.println("- Try create direcrory at path: \(absolutePath)", .verbose)
        guard !self.exist(absolutePath) else {
            Log.println("  -- Directory at this path allready exist", .verbose)
            return true
        }
        
        do {
            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true)
            Log.println("  -- Complete create directory", .verbose)
            return true
        } catch {
            return false
        }
    }
    
    @discardableResult static
    func remove(_ absolutePath: String) -> Bool {
        Log.println("- Try remove file at path: \(absolutePath)", .verbose)
        guard self.exist(absolutePath) else {
            Log.println("  -- File at this path allready not exist", .verbose)
            return true
        }
        
        do {
            try FileManager.default.removeItem(atPath: absolutePath)
            Log.println("  -- Complete remove file", .verbose)
            return true
        } catch {
            return false
        }
    }
}

public
extension File {
    
    func path(_ components: String...) -> String {
        return self.path(components)
    }
    
    func path(_ components: [String]) -> String {
        return Self.path(with: [self.projectDirectory] + components)
    }
    
    @discardableResult
    func exist(_ path: String...) -> Bool {
        return Self.exist(self.path(path))
    }
    
    @discardableResult
    func copy(_ fromPath: String, _ toPath: String) -> Bool {
        return Self.copy(self.path(fromPath), self.path(toPath))
    }
    
    @discardableResult
    func create(_ path: String...) -> Bool {
        return Self.create(self.path(path))
    }
    
    @discardableResult
    func remove(_ path: String...) -> Bool {
        return Self.remove(self.path(path))
    }
}
