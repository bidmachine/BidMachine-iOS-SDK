import Foundation

public
struct Framework {
    
    public
    enum LibType {
        case framework
        case lib
    }
    
    public
    enum Name: String {
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
    }
    
    internal let name: Name
    internal let type: LibType
    
    public
    var path: String {
        return self.type.path(self.name)
    }
    
    public
    var binPath: String {
        return self.type.binPath(self.name)
    }
    
    public
    var description: String {
        return self.path
    }
    
    public
    init(_ name: Name, _ type: LibType) {
        self.name = name
        self.type = type
    }
}

private
extension Framework.LibType {
    func binPath(_ name: Framework.Name) -> String {
        switch self {
        case .framework: return "\(name.rawValue).framework/\(name.rawValue)"
        case .lib: return "lib\(name.rawValue).a"
        }
    }
    
    func path(_ name: Framework.Name) -> String {
        switch self {
        case .framework: return "\(name.rawValue).framework"
        case .lib: return "lib\(name.rawValue).a"
        }
    }
}
