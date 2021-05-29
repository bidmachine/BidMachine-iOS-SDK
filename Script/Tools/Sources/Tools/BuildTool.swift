import Foundation
import XCBuild
import Framework
import Utils

public
class BuildTool {
    
    private
    struct Config {
        static let scheme = "BidMachine"
    }

    private
    let file: FileTool
    
    public
    init(_ file: FileTool) {
        self.file = file
    }
    
    @discardableResult public
    func build() -> Bool {
        Log.println("Start build sdk!", .info)
        
        let result =
            self.prepareBuildDirectory() &&
            self.buildFrameworks()
        
        Log.println("Finish build sdk!", result ? .success : .failure)
        
        
        return result
//            self.prepareBuildDirectory() &&
//            self.buildFrameworks() &&
//            self.prepareLibDirectory() &&
//            self.copyRequiredFrameworks() &&
//            self.makeUniversalLibs() &&
//            self.mergeFrameworks() &&
//            self.cleanMergingDependencies() &&
//            self.copyFiles() &&
//            self.cleanBuildDirectory()
    }
    
}

private
extension BuildTool {
    
    func buildFrameworks() -> Bool {
        let xcbuild = XCBuild { $0
            .appendScheme(Config.scheme)
            .appendWorkspacePath(self.file.absolutePath(.workspace))
            .appendIphonePath(self.file.absolutePath(.iphone))
            .appendSimulatorPath(self.file.absolutePath(.simulator))
        }
        
        var result = false
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            result = xcbuild.build()
            group.leave()
        }
        
        group.wait()
        return result
    }
}

private
extension BuildTool {
    
    @discardableResult
    func prepareBuildDirectory() -> Bool {
        File.remove(self.file.absolutePath(.build))
        File.remove(self.file.absolutePath(.frameworks))
        File.create(self.file.absolutePath(.iphone))
        File.create(self.file.absolutePath(.simulator))
        return true
    }
}
    
//    @discardableResult
//    func cleanMergingDependencies() -> Bool {
//        mergingMap
//            .reduce(into: [String]()) { result, item in
//                result.append(contentsOf: item.value.compactMap {
//                    if (item.key != $0) {
//                        return $0.pathToLib(.universal)
//                    }
//                    return nil
//                })
//            }
//            .forEach { self.file.removeFile($0)}
//        return true
//    }
//
//    @discardableResult
//    func copyFiles() -> Bool {
//        self.file.removeFile(Paths.frameworks)
//        self.file.createFile(Paths.frameworks)
//        self.file.copyFiles("\(Paths.build)/\(BuildType.universal)", Paths.frameworks)
//        return true
//    }
//
//    @discardableResult
//    func cleanBuildDirectory() -> Bool {
//        self.file.removeFile(Paths.build)
//        return true
//    }
//}
//
//private
//extension Build {
//
//    func copyRequiredFrameworks() -> Bool {
//        return requiredFrameworks.reduce(true) { $0 && self.copyRequiredFramework($1) }
//    }
//
//    func copyRequiredFramework(_ framework: Framework.Name) -> Bool {
//        let fromPath = framework.pathToLib(.iphoneos)
//        let toPath = framework.pathToLib(.universal)
//
//        self.file.copy(fromPath, toPath)
//        self.file.removeFile(toPath.flatMap { $0 + "/PrivateHeaders"})
//        self.file.removeFile(toPath.flatMap { $0 + "/\(framework.rawValue)"})
//
//        if self.file.fileExist(toPath) {
//            return true
//        } else {
//            Router.shared.print("Can't create reqired framework path: \(String(describing: toPath))", .failure)
//            return false
//        }
//    }
//}
//
//private
//extension Build {
//    func makeUniversalLibs() -> Bool {
//        return (requiredFrameworks + requiredLibs).reduce(true) { $0 && self.makeUniversalLib($1) }
//    }
//
//    func makeUniversalLib(_ framework: Framework.Name) -> Bool {
//        guard
//            let simulatorPath = self.file.filePath(framework.pathToBin(.iphonesimulator)),
//            let iphonePath = self.file.filePath(framework.pathToBin(.iphoneos)),
//            let universalPath = self.file.filePath(framework.pathToBin(.universal))
//        else {
//            Router.shared.print("Create universal lib for: \(framework.rawValue), file not found", .failure)
//            return false
//        }
//
//        let result = Lib.lipo(universalPath, simulatorPath, iphonePath)
//        Router.shared.print("Create universal lib for: \(framework.rawValue)", result ? .success : .failure)
//        return result
//    }
//}
//
//private
//extension Build {
//    func mergeFrameworks() -> Bool {
//        return mergingMap.reduce(true) { $0 && self.mergeFramework($1.key, $1.value) }
//    }
//
//    func mergeFramework(_ framework: Framework.Name, _ dependencies: [Framework.Name]) -> Bool {
//        let paths: [String] = dependencies.compactMap { self.file.filePath($0.pathToBin(.universal)) }
//        guard paths.count == dependencies.count else {
//            Router.shared.print("Create fat framework: \(framework.rawValue), dependecies not found", .failure)
//            return false
//        }
//
//        guard let universalPath = self.file.filePath(framework.pathToBin(.universal)) else {
//            Router.shared.print("Create fat framework: \(framework.rawValue), file not found", .failure)
//            return false
//        }
//        let result = Lib.libtool(universalPath, paths)
//        Router.shared.print("Create fat framework for: \(framework.rawValue)", result ? .success : .failure)
//        return result
//    }
//}
//
//private
//extension Framework.Name {
//    func pathToLib(_ type: BuildType) -> String? {
//        if requiredFrameworks.contains(self) {
//            return  "\(Paths.build)/\(type.rawValue)/\(self.rawValue).framework"
//        }
//        return "\(Paths.build)/\(type.rawValue)/lib\(self.rawValue).a"
//    }
//
//    func pathToBin(_ type: BuildType) -> String? {
//        if requiredFrameworks.contains(self) {
//            return self.pathToLib(type).flatMap{ $0 + "/" + self.rawValue}
//        }
//        return self.pathToLib(type)
//    }
//}
