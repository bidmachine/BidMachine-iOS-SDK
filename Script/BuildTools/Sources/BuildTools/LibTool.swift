import Foundation

public
class Lib {
    
    public static
    func lipo(_ output: String, _ input: String...) -> Bool {
        let result = Shell.shell(["lipo", "-create"] + input + ["-output", output])
        if result.code == 1 {
            Router.shared.print(result.desription, .verbose)
            return false
        }
        return true
    }
    
    public static
    func libtool(_ output: String, _ input: [String]) -> Bool {
        let result = Shell.shell(["libtool", "-static", "-o"] + [output] + input)
        if result.code == 1 {
            Router.shared.print(result.desription, .verbose)
            return false
        }
        return true
    }
}
