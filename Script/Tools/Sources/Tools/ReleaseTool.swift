//
//  File.swift
//  
//
//  Created by Ilia Lozhkin on 28.05.2021.
//

import Foundation

public
class ReleaseTool {
    
    private
    enum ReleaseType: String {
        case sdk
        case adapters
    }
    
    private
    let file: FileTool
    
    private
    let sdkProcess: SpecProcess
    
//    private
//    let adapterProcess: SpecProcess
    
    public
    init(_ file: FileTool, _ allowWarnigs: Bool) {
        self.file = file
        
        self.sdkProcess = SpecProcess(file.absolutePath(.sdkSpec),
                                      file.absolutePath(.releases),
                                      file.absolutePath(.frameworks),
                                      allowWarnigs)
    }
    
    @discardableResult public
    func release(_ type: String) -> Bool {
        if type.lowercased() == ReleaseType.sdk.rawValue {
            let spec: Spec = .spec(.BidMachine)
            return self.sdkProcess.execute(spec)
        }
        return false
    }
    
}


