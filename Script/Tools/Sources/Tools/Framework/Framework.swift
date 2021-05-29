import Foundation

public
enum Framework: String {
    
    internal
    enum LibType {
        case framework
        case lib
    }
    
    case BidMachine
    case StackAPI
    case BDMAdColonyAdapter
    case BDMAmazonAdapter
    case BDMAppRollAdapter
    case BDMCriteoAdapter
    case BDMFacebookAdapter
    case BDMMyTargetAdapter
    case BDMSmaatoAdapter
    case BDMTapjoyAdapter
    case BDMVungleAdapter
    case BDMMRAIDAdapter
    case BDMVASTAdapter
    case BDMNASTAdapter
    case BDMIABAdapter
    
    internal var type: LibType {
        let frameworks: [Framework] = [.BidMachine, .StackAPI]
        return frameworks.contains(self) ? .framework : .lib
    }
    
    internal
    var binPath: String {
        switch self.type {
        case .framework: return "\(self.rawValue).framework/\(self.rawValue)"
        case .lib: return "lib\(self.rawValue).a"
        }
    }
    
    internal
    var path: String {
        switch self.type {
        case .framework: return "\(self.rawValue).framework"
        case .lib: return "lib\(self.rawValue).a"
        }
    }
    
    public
    var description: String {
        return self.path
    }
}
