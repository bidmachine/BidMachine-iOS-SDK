import Foundation

public
struct Target {
    
    fileprivate
    let dependencies:[Framework]
    
    fileprivate
    let framework: Framework
    
    public
    init(_ framework: Framework, _ dependencies: Framework...) {
        self.dependencies = dependencies
        self.framework = framework
    }
}

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
    func execute(_ target: Target) -> Bool {
        return
            target.dependencies.reduce(true) { $0 && self.copyIfNeeded($1) } &&
            target.dependencies.reduce(true) { $0 && self.createUniversalFramework($1) } &&
            self.createFatFramework(target.framework, target.dependencies, true)
    }
    
    @discardableResult private
    func copyIfNeeded(_ framework: Framework) -> Bool {
        if framework.type == .lib {
            return true
        }
        
        let path = File.path(with: iphoneLibPath, framework.path)
        guard File.exist(path) else {
            Log.println("Framework not exist at path: \(path)", .failure)
            return false
        }
        
        return
            File.copy(File.path(with: iphoneLibPath, framework.path), File.path(with: universalLibPath, framework.path)) &&
            File.remove(File.path(with: universalLibPath, framework.path, "PrivateHeaders")) &&
            File.remove(File.path(with: universalLibPath, framework.binPath))
    }
    
    @discardableResult private
    func createUniversalFramework(_ framework: Framework) -> Bool {
        Log.println("Try create universal lib for: \(framework.description)", .info)
        let iphonePath = File.path(with: self.iphoneLibPath, framework.binPath)
        let simulatorPath = File.path(with: self.simulatorLibPath, framework.binPath)
        let universalPath = File.path(with: self.universalLibPath, framework.binPath)
        
        guard File.exist(iphonePath) else {
            Log.println("Framework: \(framework.description) not contain required iphone lib for path: \(iphonePath)", .failure)
            return false
        }
        
        guard File.exist(simulatorPath) else {
            Log.println("Framework: \(framework.description) not contain required simulator lib for path: \(simulatorPath)", .failure)
            return false
        }
        
        let result =
            File.create(self.universalLibPath) &&
            Lib.lipo(universalPath, simulatorPath, iphonePath)
        
        Log.println("Create universal lib for: \(framework.description)", result ? .success : .failure)
        return result
    }
    
    @discardableResult private
    func createFatFramework(_ framework: Framework, _ frameworks: [Framework], _ removeSubmodule: Bool) -> Bool {
        if frameworks.count == 1 && frameworks.contains(framework) {
            return true
        }
        
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
            Log.println("Can't create fat lib for: \(framework.description)", .failure)
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
            if ($0 != framework) {
                File.remove(File.path(with: self.universalLibPath, $0.path))
            }
        }
        return true
    }
}
