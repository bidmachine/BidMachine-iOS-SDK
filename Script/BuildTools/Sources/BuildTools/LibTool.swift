import Foundation

public
class Lib {
    
    @discardableResult public static
    func lipo(_ output: String, _ input: String...) -> Bool {
        return Shell.shell(["lipo", "-create"] + input + ["-output", output])
    }
    
    @discardableResult public static
    func libtool(_ output: String, _ input: [String]) -> Bool {
        return Shell.shell(["libtool", "-static", "-o"] + [output] + input)
    }
}
