import Foundation

public
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

public
class Log {
    
    public
    var verbose = false
    
    public
    func println(_ message: String, _ type: LogType) {
        guard (type != .verbose) || type == .verbose && self.verbose else {
            return
        }
        self._println("\(type.color())\(Date()) [\(type.rawValue.uppercased())] \(message)\n")
    }
    
    public
    init() {
        self._println("\n--------------------\n")
    }
    
    private
    func _println(_ message: String) {
        FileHandle.standardOutput.write(message.data(using: .ascii)!)
    }
}

public
class Logging {
    
    public static
    func println(_ log: String){
        print(log)
    }
    
    public static
    func printf(_ path: String, _ log: String) {
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                try log.write(toFile: path, atomically: false, encoding: .utf8)
            } catch {
                
            }
        } else {
            
        }
    }
}
