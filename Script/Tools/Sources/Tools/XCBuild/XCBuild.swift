import Foundation

internal
class XCBuildBuilder {
    
    fileprivate private(set) var workspacePath: String = ""
    fileprivate private(set) var scheme: String = ""
    fileprivate private(set) var iphonePath: String = ""
    fileprivate private(set) var simulatorPath: String = ""
    
    @discardableResult
    internal func appendScheme(_ scheme: String) -> XCBuildBuilder {
        self.scheme = scheme
        return self
    }
    
    @discardableResult
    internal func appendWorkspacePath(_ path: String) -> XCBuildBuilder {
        self.workspacePath = path
        return self
    }
    
    @discardableResult
    internal func appendIphonePath(_ path: String) -> XCBuildBuilder {
        self.iphonePath = path
        return self
    }
    
    @discardableResult
    internal func appendSimulatorPath(_ path: String) -> XCBuildBuilder {
        self.simulatorPath = path
        return self
    }
}

internal
class XCBuild {
    
    internal
    enum BuildType: String {
        case iphonesimulator
        case iphoneos
    }
    
    private let config: XCBuildBuilder
    
    internal
    init(_ builder: (XCBuildBuilder) -> Void) {
        let config = XCBuildBuilder()
        builder(config)
        self.config = config
    }
    
    @discardableResult internal
    func build() -> Bool {
        guard
            File.exist(self.config.workspacePath) else {
            Log.println("Can't find workspace for path: \(self.config.workspacePath)", .failure)
            return false
        }
        
        Log.println("-- Workspace: \(self.config.workspacePath)", .info)
        Log.println("-- Scheme: \(self.config.scheme)", .info)
        
        return
            self._build(.iphoneos) &&
            self._build(.iphonesimulator)
    }
    
    @discardableResult private
    func _build(_ type: BuildType) -> Bool {
        return Shell.shell(["xcodebuild",
                            "-workspace", self.config.workspacePath,
                            "-scheme", self.config.scheme,
                     "-sdk", type.rawValue,
                     "-configuration",
                     "Release",
                     "ARCHS=\(type.arch())",
                     "STRIP_INSTALLED_PRODUCT=YES",
                     "LINK_FRAMEWORKS_AUTOMATICALLY=NO",
                     "CLANG_DEBUG_INFORMATION_LEVEL=-gline-tables-only",
                     "OTHER_CFLAGS=-fembed-bitcode -Qunused-arguments",
                     "IPHONEOS_DEPLOYMENT_TARGET=10.0",
                     "MACH_O_TYPE=staticlib",
                     "DEPLOYMENT_POSTPROCESSING=YES",
                     "GCC_GENERATE_DEBUGGING_SYMBOLS=NO",
                     "build",
                     "CONFIGURATION_BUILD_DIR=\(type == .iphoneos ? self.config.iphonePath : self.config.simulatorPath)"], true)
    }
}

fileprivate
extension XCBuild.BuildType {
    func arch() -> String {
        switch self {
        case .iphoneos: return "arm64 armv7"
        case .iphonesimulator: return "i386 x86_64"
        }
    }
}
