import Foundation
import CLISpinner

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
    func shell(_ args: [String]) -> Bool {
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
        
        Log.println(message, .verbose)
        
        return task.terminationStatus == 0
    }
}
