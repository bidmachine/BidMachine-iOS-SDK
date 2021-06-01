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
        
        guard let fileTool = File(nil) else {
            Shell.exitWithFailure()
            return
        }
        
        guard let buildTool = BuildTool(fileTool) else {
            Shell.exitWithFailure()
            return
        }
        
        buildTool.build() ? Shell.exitWithSuccess() : Shell.exitWithFailure()
    }
    
    func releaseSdk(_ type: [String], _ allowWarnings: Bool) {
        
        guard let fileTool = File(nil) else {
            Shell.exitWithFailure()
            return
        }
        
        guard let releaseTool = ReleaseTool(fileTool, allowWarnings) else {
            Shell.exitWithFailure()
            return
        }
        
        releaseTool.release(type)
        
    }
}
