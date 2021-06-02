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
        let result = self._build()
        Log.println("Finish build sdk!", result ? .success : .failure)
        
        return result
    }
}

private
extension BuildTool {
    func _build() -> Bool {
        let targets = Config.targets.compactMap { Target($0, self.file.workDirectory) }.compactMap { $0 }
        if targets.count != Config.targets.count {
            Log.println("Cant't create all required targets", .failure)
            return false
        }
        
        let result =
            self.cleanBuildDirectory(true) &&
            self.buildFrameworks() &&
            self.prepareTargets(targets) &&
            self.cleanBuildDirectory(false)
        
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
    func prepareTargets(_ targets: [Target]) -> Bool {
        let frameworks = targets.compactMap { $0.framework }
        
        var result =
            frameworks.filter { $0.isFramework }.reduce(true) { $0 && $1.copy() } &&
            frameworks.reduce(true) { $0 && $1.createUniversal() }
        
        result =
            result &&
            Config.targetDependencies.reduce(true) {
                let dependencies = $1.value.compactMap{ Target($0, self.file.workDirectory)}.compactMap{ $0.framework }
                guard let framework = Target($1.key, self.file.workDirectory).flatMap({ $0.framework })
                else { return $0 }
                
                return $0 && framework.createFat(dependencies, true)
            }
        return true
    }
}
