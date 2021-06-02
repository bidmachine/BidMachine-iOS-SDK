import Foundation

internal
enum LogType: String {
    case info
    case warning
    case success
    case failure
    case verbose
    
    func color() -> String {
        let colorCode = "\u{001B}[0;&&m"
        switch self {
        case .info: return colorCode.replacingOccurrences(of: "&&", with: "33")
        case .warning: return colorCode.replacingOccurrences(of: "&&", with: "35")
        case .success: return colorCode.replacingOccurrences(of: "&&", with: "32")
        case .failure: return colorCode.replacingOccurrences(of: "&&", with: "31")
        case .verbose: return colorCode.replacingOccurrences(of: "&&", with: "36")
        }
    }
}

internal
class Log {
    
    internal static
    let shared = Log()
    
    internal
    var verbose = false
    
    internal static
    func println(_ message: String, _ type: LogType) {
        Self.shared.println(message, type)
    }
    
    internal
    init() {
        self._println("\n--------------------\n")
    }
    
    private
    func println(_ message: String, _ type: LogType) {
        guard message != "" else {
            return
        }
        
        guard (type != .verbose) || type == .verbose && self.verbose else {
            return
        }
        self._println("\(type.color())\(Date()) [\(type.rawValue.uppercased())] \(message)\n")
    }
    
    private
    func _println(_ message: String) {
        FileHandle.standardOutput.write(message.data(using: .ascii)!)
    }
}

internal
extension Log {
    
    static
    func completionLog(_ value: Bool, _ message: String, _ type: LogType) -> Bool {
        Self.println(message, value ? type : .failure)
        return value
    }
}
