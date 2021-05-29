import Foundation
import Utils

public
struct FrameworkProcess {
    
    private let iphoneLibPath: String
    private let simulatorLibPath: String
    private let universalLibPath: String
    
    public
    init(_ iphoneLibPath: String,
         _ simulatorLibPath: String,
         _ universalLibPath: String) {
        
        self.iphoneLibPath = iphoneLibPath
        self.simulatorLibPath = simulatorLibPath
        self.universalLibPath = universalLibPath
    }
}

public
extension FrameworkProcess {
    
    @discardableResult
    func copyIfNeeded(_ framework: Framework) -> Bool {
        if framework.type == .lib {
            return true
        }
        
        let path = File.path(with: iphoneLibPath, framework.path)
        guard File.exist(path) else {
            return false
        }
        
        return
            File.copy(File.path(with: iphoneLibPath, framework.path), File.path(with: universalLibPath, framework.path)) &&
            File.remove(File.path(with: universalLibPath, framework.path, "PrivateHeaders")) &&
            File.remove(File.path(with: universalLibPath, framework.binPath))
    }
    
    @discardableResult
    func createUniversalFramework(_ framework: Framework) -> Bool {
        Log.println("Try create universal lib for: \(framework.description)", .info)
        let iphonePath = File.path(with: self.iphoneLibPath, framework.binPath)
        let simulatorPath = File.path(with: self.simulatorLibPath, framework.binPath)
        let universalPath = File.path(with: self.universalLibPath, framework.binPath)
        
        guard File.exist(iphonePath) else {
            Log.println("Framework: \(framework.description) not required iphone lib for path: \(iphonePath)", .failure)
            return false
        }
        
        guard File.exist(simulatorPath) else {
            Log.println("Framework: \(framework.description) not required simulator lib for path: \(simulatorPath)", .failure)
            return false
        }
        
        let result =
            File.create(self.universalLibPath) &&
            Lib.lipo(universalPath, simulatorPath, iphonePath)
        
        Log.println("Create universal lib for: \(framework.description)", result ? .success : .failure)
        return result
    }
    
    @discardableResult
    func createFatFramework(_ framework: Framework, _ frameworks: [Framework], _ removeSubmodule: Bool) -> Bool {
        Log.println("Try create fat lib for: \(framework.description)", .info)
        Log.println("-- Components: \(frameworks.compactMap { $0.description }.joined(separator: ", "))", .info)
        
        let exists: Bool = frameworks.reduce(true) {
            let exist = File.exist(File.path(with: self.universalLibPath, $1.binPath))
            if !exist {
                Log.println("-- Not found fat framework component: \($1.description)", .failure)
            }
            return $0 && exist
        }
        guard exists else {
            Log.println("Can't create fat lib for: \(framework.description)", .info)
            return false
        }
        
        let result =
            Lib.libtool(File.path(with: self.universalLibPath, framework.binPath),
                        frameworks.compactMap{ File.path(with: self.universalLibPath, $0.binPath) }) &&
            (removeSubmodule ? self.removeSubmodule(framework, frameworks) : true)
        
        Log.println("Create fat lib for: \(framework.description)", result ? .success : .failure)
        return result
    }
    
    @discardableResult private
    func removeSubmodule(_ framework: Framework, _ frameworks: [Framework]) -> Bool {
        frameworks.forEach {
            if ($0.name != framework.name) {
                File.remove(File.path(with: self.universalLibPath, $0.binPath))
            }
        }
        return true
    }
}
