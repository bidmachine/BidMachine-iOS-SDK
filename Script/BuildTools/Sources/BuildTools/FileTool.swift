import Foundation

public
class File {
    
    private lazy
    var manager: FileManager = {
        FileManager.default
    }()
    
    private lazy
    var directory: String = {
        FileManager.default.currentDirectoryPath
    }()
    
    private lazy
    var projectDirectory: String? = {
        URL(string: self.directory).flatMap { $0.deletingLastPathComponent() }.flatMap { $0.absoluteString }
    }()
}

public
extension File {
    
    func rootDirectory() -> String? {
        return self.projectDirectory
    }
    
    static
    func fileExist(_ absolutePath: String?) -> Bool {
        guard let path = absolutePath
        else { return false }
        return FileManager.default.fileExists(atPath: path)
    }
    
    func fileExist(_ relativePath: String?) -> Bool {
        guard let path = self.filePath(relativePath)
        else { return false }
        return self.manager.fileExists(atPath: path)
    }
    
    func filePath(_ relativePath: String?) -> String? {
        guard let pwd = self.projectDirectory,
              let path = relativePath,
              let pathUrl = URL(string: path, relativeTo: URL(string: pwd))
        else { return nil }
        return pathUrl.absoluteString
    }
    
    func createFile(_ relativePath: String?) {
        guard let path = self.filePath(relativePath),
              !self.fileExist(relativePath)
        else { return }
        try? self.manager.createDirectory(atPath: path,
                                          withIntermediateDirectories: true,
                                          attributes: nil)
    }
    
    func removeFile(_ relativePath: String?) {
        guard let path = self.filePath(relativePath),
              self.fileExist(relativePath)
        else { return }
        try? self.manager.removeItem(atPath: path)
    }
}

public
extension File {
    
    func copy(_ from: String?, _ to: String?) {
        guard let fromPath = self.filePath(from),
              let toPath = self.filePath(to),
              self.fileExist(from)
        else { return }
        try? self.manager.copyItem(atPath: fromPath, toPath: toPath)
    }
    
    func copyFiles(_ from: String?, _ to: String?) {
        guard self.fileExist(from),
              self.fileExist(to),
              let files = try? self.manager.contentsOfDirectory(atPath: self.filePath(from)!)
        else { return }
        files.forEach { self.copy("\(from!)/\($0)", "\(to!)/\($0)") }
    }
}
