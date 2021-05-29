import Foundation

public
class Router {
    
    public static
    let shared = Router()
    
    public
    var verbose: Bool {
        get { Log.shared.verbose }
        set { Log.shared.verbose = newValue }
    }
}

public
extension Router {
    
    func buildSdk() {
        
        guard let fileTool = FileTool(nil) else {
            return
        }
        
        let buildTool = BuildTool(fileTool)
        buildTool.build()
        
    
//        let git = Git(absolute: file.rootDirectory())
//        git?.status()
//        git?.createTag("test_1", "test tag", true)
//        git?.deleteTag("test_1", true)
//        _ = git.flatMap { $0.status() }
        
        
//        self.print("Build complete", self.build.build() ? .success : .failure)
        
//        var url = URL(string:  FileManager.default.currentDirectoryPath)
//        url = url!.deletingLastPathComponent()
//        self.filePath = url!.absoluteString
//        self.print("Start build sdk", .info)
//        self.print("\(self.filePath!)", .warning)
//
//        DispatchQueue.global(qos: .userInitiated).async {
//            let xcbuild = XCBuild(self.filePath! + "BidMachine.xcworkspace", "BidMachine")
//            let result = xcbuild.build()
//
//            self.print("Build complete", result ? .success : .failure)
//
//            Shell.exitWithSuccess()
//        }
//        RunLoop.current.run()
    }
}
