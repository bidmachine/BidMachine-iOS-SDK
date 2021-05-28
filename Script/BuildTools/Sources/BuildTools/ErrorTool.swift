import Foundation

public
enum ErrorService: LocalizedError  {
    
    case unknown(String)
    case invalidOption
    case invalidArgument
    
    public
    var errorDescription: String? {
        switch self {
        case .unknown(let message): return "Any unknown error with description: \(message)"
        case .invalidOption: return "Command line should contain any options. See --help"
        case .invalidArgument: return "Argument should be [sdk] or [adapter all] or [adapter BDMNameAdapter]"
        }
    }
}
