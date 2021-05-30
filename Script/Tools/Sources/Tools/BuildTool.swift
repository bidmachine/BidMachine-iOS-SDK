import Foundation

public
class BuildTool {
    
    private
    struct Config {
        static let scheme = "BidMachine"
        
        static let targets =
            [
                Target(.BDMAdColonyAdapter, .BDMAdColonyAdapter),
                Target(.BDMAmazonAdapter, .BDMAmazonAdapter),
                Target(.BDMAppRollAdapter, .BDMAppRollAdapter),
                Target(.BDMCriteoAdapter, .BDMCriteoAdapter),
                Target(.BDMFacebookAdapter, .BDMFacebookAdapter),
                Target(.BDMMyTargetAdapter, .BDMMyTargetAdapter),
                Target(.BDMSmaatoAdapter, .BDMSmaatoAdapter),
                Target(.BDMTapjoyAdapter, .BDMTapjoyAdapter),
                Target(.BDMVungleAdapter, .BDMVungleAdapter),
                Target(.BidMachine, .BidMachine, .StackAPI),
                Target(.BDMIABAdapter, .BDMVASTAdapter, .BDMNASTAdapter, .BDMMRAIDAdapter)
            ]
    }

    private
    let file: FileTool
    
    private
    let frameworkProcess: FrameworkProcess
    
    public
    init(_ file: FileTool) {
        self.file = file
        self.frameworkProcess = FrameworkProcess(file.absolutePath(.iphone),
                                                 file.absolutePath(.simulator),
                                                 file.absolutePath(.universal))
    }
    
    @discardableResult public
    func build() -> Bool {
        Log.println("Start build sdk!", .info)
        
        
        let result =
            self.prepareBuildDirectory() &&
            self.buildFrameworks() &&
            Config.targets.reduce(true) { $0 && self.frameworkProcess.execute($1) } &&
            self.copyToFrameworksDir() &&
            self.cleanBuildDirectory()
        
        Log.println("Finish build sdk!", result ? .success : .failure)
        
        return result
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
    
//    func copyFrameworks() -> Bool {
//        return Config.requiredFrameworks.reduce(true) { $0 && self.frameworkProcess.copyIfNeeded($1) }
//    }
//
//    func createUniversalFrameworks() -> Bool {
//        return Config.requiredFrameworks.reduce(true) { $0 && self.frameworkProcess.createUniversalFramework($1) }
//    }
//
//    func createFatFrameworks() -> Bool {
//        return Config.fatFrameworks.reduce(true) { $0 && self.frameworkProcess.createFatFramework($1.key, $1.value, true) }
//    }
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
    
    @discardableResult
    func cleanBuildDirectory() -> Bool {
        File.remove(self.file.absolutePath(.build))
        return true
    }
    
    func copyToFrameworksDir() -> Bool {
        File.copy(self.file.absolutePath(.universal), self.file.absolutePath(.frameworks))
    }
}
