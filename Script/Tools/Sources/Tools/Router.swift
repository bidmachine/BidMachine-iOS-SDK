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
            Shell.exitWithFailure()
            return
        }
        
        let buildTool = BuildTool(fileTool)
        buildTool.build() ? Shell.exitWithSuccess() : Shell.exitWithFailure()
    }
    
    func releaseSdk(_ type: String) {
        
    }
}
