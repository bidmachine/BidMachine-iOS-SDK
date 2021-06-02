import Foundation

internal
class Lib {
    
    @discardableResult internal static
    func lipo(_ output: String, _ input: String...) -> Bool {
        return Shell.shell(["lipo", "-create"] + input + ["-output", output])
    }
    
    @discardableResult internal static
    func libtool(_ output: String, _ input: [String]) -> Bool {
        return Shell.shell(["libtool", "-static", "-o"] + [output] + input)
    }
}
