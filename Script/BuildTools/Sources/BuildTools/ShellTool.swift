import Foundation
import CLISpinner

public typealias ShellResult = (code: Int32, desription: String)

public
struct Shell {
    
    public static
    func exitWithSuccess(){
        exit(0)
    }
    
    public static
    func exitWithFailure(){
        exit(1)
    }

    public static
    func shell(_ args: String...) -> ShellResult {
        return self.shell(args)
    }
    
    public static
    func shell(_ args: [String]) -> ShellResult {
        let task = Process()
        let pipe = Pipe()
        let spinner = Spinner(pattern: .arrow3)
        
        var message = ""
        
        task.launchPath = "/usr/bin/env"
        task.arguments = args
        task.standardOutput = pipe
        task.standardError = pipe
        
        let group = DispatchGroup()
        group.enter()
        pipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            if data.isEmpty {
                pipe.fileHandleForReading.readabilityHandler = nil
                group.leave()
            } else {
                message.append(String(data: data, encoding: .utf8)!)
            }
        }
        spinner.start()

        task.launch()
        task.waitUntilExit()
        group.wait()
        
        spinner.stop()
        
        return ShellResult(task.terminationStatus, message)
    }
}



