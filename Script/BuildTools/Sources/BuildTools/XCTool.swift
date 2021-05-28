import Foundation

public
class XCBuild {
    
    private let workspace: String
    private let scheme: String
    
    public
    init(_ workspace: String, _ scheme: String) {
        self.workspace = workspace
        self.scheme = scheme
    }
    
    @discardableResult public
    func build() -> Bool {
        return
            self._build(.iphoneos) &&
            self._build(.iphonesimulator)
    }
    
    @discardableResult private
    func _build(_ type: BuildType) -> Bool {
        return Shell.shell(["xcodebuild",
                     "-workspace", self.workspace,
                     "-scheme", self.scheme,
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
                     "CONFIGURATION_BUILD_DIR=/Users/assassinsc/Desktop/BidMachine-iOS-SDK/BidMachineRelease/build/\(type.rawValue)"])
    }
}

fileprivate
extension BuildType {
    func arch() -> String {
        switch self {
        case .iphoneos: return "arm64 armv7"
        case .iphonesimulator: return "i386 x86_64"
        default: return ""
        }
    }
}
