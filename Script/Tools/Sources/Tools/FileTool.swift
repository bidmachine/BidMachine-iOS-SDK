import Foundation

public
class FileTool {
    
    public
    enum Dir {
        case project
        case workspace
        
        case build
        case frameworks
        case releases
        
        case iphone
        case simulator
        case universal
        
        case adapterSpec
        case sdkSpec
    }
    
    private
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
extension FileTool {
    func absolutePath(_ dir: FileTool.Dir) -> String {
        return  dir.path() != "" ? File.path(with: self.projectDirectory, dir.path()) : File.path(with: self.projectDirectory)
    }
}

private
extension FileTool.Dir {
    func path() -> String {
        switch self {
        case .project: return ""
        case .workspace: return "BidMachine.xcworkspace"
            
        case .build: return "BidMachineRelease/build"
        case .frameworks: return "BidMachineRelease/Frameworks"
        case .releases: return "BidMachineRelease/Releases"
            
        case .iphone: return "BidMachineRelease/build/iphoneos"
        case .simulator: return "BidMachineRelease/build/iphonesimulator"
        case .universal: return "BidMachineRelease/build/universal"
            
        case .adapterSpec: return "BidMachine-iOS-Adaptors"
        case .sdkSpec: return "BidMachineRelease"
        }
    }
}
//
//
//public
//extension File {
//
//    static
//    func path(with components: String...) -> String {
//        return components.joined(separator: "/")
//    }
//
//    @discardableResult static
//    func exist(_ absolutePath: String) -> Bool {
//        guard FileManager.default.fileExists(atPath: absolutePath) else {
//            Router.shared.print("File not exist at path: \(absolutePath) ", .failure)
//            return false
//        }
//        return true
//    }
//
//    @discardableResult static
//    func copy(_ fromAbsolutePath: String, _ toAbsolutePath: String) -> Bool {
//        Router.shared.print("- Try copy file \n-- From: \(fromAbsolutePath) \n-- To: \(toAbsolutePath)", .verbose)
//        guard self.exist(fromAbsolutePath) else {
//            Router.shared.print("Non existent copying file at path: \(fromAbsolutePath)", .failure)
//            return false
//        }
//
//        guard
//            let result = URL(string: toAbsolutePath)
//                .flatMap({ $0.deletingLastPathComponent()})
//                .flatMap ({ $0.absoluteString })
//                .flatMap({ self.create($0) }),
//            result == true
//        else {
//            Router.shared.print("Root file not exist for direct path: \(toAbsolutePath)", .failure)
//            return false
//        }
//
//        guard !self.exist(toAbsolutePath) else {
//            Router.shared.print("Copy target allready contain same file at path: \(toAbsolutePath)", .failure)
//            return false
//        }
//
//        do {
//            try FileManager.default.copyItem(atPath: fromAbsolutePath, toPath: toAbsolutePath)
//            Router.shared.print("-- Complete copy files", .verbose)
//            return true
//        } catch {
//            return false
//        }
//    }
//
//    @discardableResult static
//    func create(_ absolutePath: String) -> Bool {
//        Router.shared.print("- Try create direcrory at path: \(absolutePath)", .verbose)
//        guard self.fileExist(absolutePath) else {
//            Router.shared.print("-- Directory allready exist at path: \(absolutePath)", .verbose)
//            return true
//        }
//
//        do {
//            try FileManager.default.createDirectory(atPath: absolutePath, withIntermediateDirectories: true)
//            Router.shared.print("-- Complete create directory", .verbose)
//            return true
//        } catch {
//            return false
//        }
//    }
//
//    @discardableResult static
//    func remove(_ absolutePath: String) -> Bool {
//        Router.shared.print("- Try remove file at path: \(absolutePath)", .verbose)
//        guard self.exist(absolutePath) else {
//            Router.shared.print("- File at this path not exist: \(absolutePath)", .verbose)
//            return true
//        }
//
//        do {
//            try FileManager.default.removeItem(atPath: absolutePath)
//            Router.shared.print("- File removed: \(absolutePath)", .verbose)
//            return true
//        } catch {
//            return false
//        }
//    }
//}
//
//public
//extension File {
//
//
//
//    func rootDirectory() -> String? {
//        return self.projectDirectory
//    }
//
//    static
//    func fileExist(_ absolutePath: String?) -> Bool {
//        guard let path = absolutePath
//        else { return false }
//        return FileManager.default.fileExists(atPath: path)
//    }
//
//    func fileExist(_ relativePath: String?) -> Bool {
//        guard let path = self.filePath(relativePath)
//        else { return false }
//        return self.manager.fileExists(atPath: path)
//    }
//
//    func filePath(_ relativePath: String?) -> String? {
//        guard let pwd = self.projectDirectory,
//              let path = relativePath,
//              let pathUrl = URL(string: path, relativeTo: URL(string: pwd))
//        else { return nil }
//        return pathUrl.absoluteString
//    }
//
//    func createFile(_ relativePath: String?) {
//        guard let path = self.filePath(relativePath),
//              !self.fileExist(relativePath)
//        else { return }
//        try? self.manager.createDirectory(atPath: path,
//                                          withIntermediateDirectories: true,
//                                          attributes: nil)
//    }
//
//    func removeFile(_ relativePath: String?) {
//        guard let path = self.filePath(relativePath),
//              self.fileExist(relativePath)
//        else { return }
//        try? self.manager.removeItem(atPath: path)
//    }
//}
//
//public
//extension File {
//
//    func copy(_ from: String?, _ to: String?) {
//        guard let fromPath = self.filePath(from),
//              let toPath = self.filePath(to),
//              self.fileExist(from)
//        else { return }
//        try? self.manager.copyItem(atPath: fromPath, toPath: toPath)
//    }
//
//    func copyFiles(_ from: String?, _ to: String?) {
//        guard self.fileExist(from),
//              self.fileExist(to),
//              let files = try? self.manager.contentsOfDirectory(atPath: self.filePath(from)!)
//        else { return }
//        files.forEach { self.copy("\(from!)/\($0)", "\(to!)/\($0)") }
//    }
//}
