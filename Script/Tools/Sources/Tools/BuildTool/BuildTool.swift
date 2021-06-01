import Foundation

internal
class BuildTool {
    
    private
    struct Config {
        static let scheme = "BidMachine"
        static let workspace = "BidMachine.xcworkspace"

        static let targets: [Target.Name] =
            [
                .BidMachine,
                .StackAPI,
                .BDMAdColonyAdapter,
                .BDMAmazonAdapter,
                .BDMAppRollAdapter,
                .BDMCriteoAdapter,
                .BDMFacebookAdapter,
                .BDMMyTargetAdapter,
                .BDMSmaatoAdapter,
                .BDMTapjoyAdapter,
                .BDMVungleAdapter,
                .BDMVASTAdapter,
                .BDMNASTAdapter,
                .BDMMRAIDAdapter
            ]
        
        static let targetDependencies: [Target.Name : [Target.Name]] =
            [
                .BidMachine : [.BidMachine, .StackAPI],
                .BDMIABAdapter : [.BDMVASTAdapter, .BDMMRAIDAdapter, .BDMNASTAdapter],
            ]
    }

    private
    let file: File
    
    internal
    init?(_ file: File) {
        self.file = file
    }
    
    @discardableResult internal
    func build() -> Bool {
        Log.println("Start build sdk!", .info)
        
        
        let result =
            self.cleanBuildDirectory(true) &&
            self.buildFrameworks() &&
            self.prepareTargets() &&
            self.cleanBuildDirectory(false)

        Log.println("Finish build sdk!", result ? .success : .failure)
        
        return result
    }
}

private
extension BuildTool {
    
    func buildFrameworks() -> Bool {
        let xcbuild = XCBuild { $0
            .appendScheme(Config.scheme)
            .appendWorkspacePath(self.file.path(Config.workspace))
            .appendIphonePath(self.file.path(Target.frameworkDir(.iphoneos)))
            .appendSimulatorPath(self.file.path(Target.frameworkDir(.iphonesimulator)))
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
    func cleanBuildDirectory(_ removeUniversal: Bool) -> Bool {
        self.file.remove(Target.frameworkDir(.iphoneos))
        self.file.remove(Target.frameworkDir(.iphonesimulator))
        if removeUniversal {
            self.file.remove(Target.frameworkDir(.universal))
        }
        return true
    }
}

private
extension BuildTool {

    @discardableResult
    func prepareTargets() -> Bool {
        let frameworks = Config.targets.compactMap { Target($0).framework }
        
        var result =
            frameworks.filter { $0.isFramework }.reduce(true) { $0 && self.copyFramework($1) } &&
            frameworks.reduce(true) { $0 && self.createUniversalFramework($1) }
        
        result =
            result &&
            Config.targetDependencies.reduce(true) {
                $0 && self.createFatFramework(Target($1.key).framework,
                                              $1.value.compactMap{Target($0).framework},
                                              true)
            }
        return result
    }

    @discardableResult
    func copyFramework(_ framework: Framework) -> Bool {
        let path = self.file.path(framework.path(.iphoneos))
        guard File.exist(path) else {
            Log.println("Framework not exist at path: \(path)", .failure)
            return false
        }

        return
            self.file.copy(framework.path(.iphoneos), framework.path(.universal)) &&
            self.file.remove(framework.path(.universal), "PrivateHeaders") &&
            self.file.remove(framework.binPath(.universal))
    }

    @discardableResult
    func createUniversalFramework(_ framework: Framework) -> Bool {
        Log.println("Try create universal lib for: \(framework.name)", .info)
        let iphonePath = self.file.path(framework.binPath(.iphoneos))
        let simulatorPath = self.file.path(framework.binPath(.iphonesimulator))
        let universalPath = self.file.path(framework.binPath(.universal))

        guard File.exist(iphonePath) else {
            Log.println("Framework: \(framework.name) not contain required iphone lib for path: \(iphonePath)", .failure)
            return false
        }

        guard File.exist(simulatorPath) else {
            Log.println("Framework: \(framework.name) not contain required simulator lib for path: \(simulatorPath)", .failure)
            return false
        }

        let result =
            self.file.create(Target.frameworkDir(.universal)) &&
            Lib.lipo(universalPath, simulatorPath, iphonePath)

        Log.println("Create universal lib for: \(framework.name)", result ? .success : .failure)
        return result
    }

    @discardableResult
    func createFatFramework(_ framework: Framework, _ frameworks: [Framework], _ removeSubmodule: Bool) -> Bool {
        Log.println("Try create fat lib for: \(framework.name)", .info)
        Log.println("-- Components: \(frameworks.compactMap { $0.name }.joined(separator: ", "))", .info)

        let exists: Bool = frameworks.reduce(true) {
            let exist = self.file.exist($1.binPath(.universal))
            if !exist {
                Log.println("-- Not found fat framework component: \($1.name)", .failure)
            }
            return $0 && exist
        }
        guard exists else {
            Log.println("Can't create fat lib for: \(framework.name)", .failure)
            return false
        }

        let result =
            Lib.libtool(self.file.path(framework.binPath(.universal)), frameworks.compactMap{ self.file.path($0.binPath(.universal))}) &&
            (removeSubmodule ? self.removeSubmodule(framework, frameworks) : true)

        Log.println("Create fat lib for: \(framework.name)", result ? .success : .failure)
        return result
    }

    @discardableResult
    func removeSubmodule(_ framework: Framework, _ frameworks: [Framework]) -> Bool {
        frameworks.forEach {
            if ($0.name != framework.name) {
                self.file.remove($0.path(.universal))
            }
        }
        return true
    }
}
