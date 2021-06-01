//
//  ReleaseTool.swift
//  
//
//  Created by Ilia Lozhkin on 28.05.2021.
//

import Foundation


internal
class ReleaseTool {
    
    private
    struct Config {
        static let gitSDKDir = ""
        static let gitAdaptersDir = "BidMachine-iOS-Adaptors"
        
        static let targets: [Target.Name] =
            [
                .BidMachine,
                .BDMAdColonyAdapter,
                .BDMAmazonAdapter,
                .BDMAppRollAdapter,
                .BDMCriteoAdapter,
                .BDMFacebookAdapter,
                .BDMMyTargetAdapter,
                .BDMSmaatoAdapter,
                .BDMTapjoyAdapter,
                .BDMVungleAdapter,
                .BDMIABAdapter
            ]
    }
    
    private
    var adapterService: ReleaseServiceProtocol
    
    private
    var sdkService: ReleaseServiceProtocol
    
    internal
    init?(_ file: File, _ allowWarnings: Bool) {
        guard let gitSdk = Git(absolute: file.path(Config.gitSDKDir)),
              let gitAdapters = Git(absolute: file.path(Config.gitAdaptersDir))
        else {
            return nil
        }
        
        self.adapterService = ReleaseService(file, gitAdapters, allowWarnings)
        self.sdkService = ReleaseService(file, gitSdk, allowWarnings)
    }
    
    @discardableResult internal
    func release(_ type: [String]) -> Bool {
        if type.contains("All") {
            return self.prepareRelease(Config.targets.compactMap { Target($0) })
        }
        
        var targets = type.compactMap { Target.Name(rawValue: $0) }.compactMap { Target($0) }
        if type.contains("Adapters") {
            targets = targets.filter{ !$0.spec.isAdapter }
            targets = targets + Config.targets.compactMap { Target($0) }.filter { $0.spec.isAdapter }
        }

        if type.contains("Sdk") {
            targets = targets.filter{ $0.spec.isAdapter }
            targets = targets + Config.targets.compactMap { Target($0) }.filter { !$0.spec.isAdapter }
        }
        
        return self.prepareRelease(targets)
    }
}

private
extension ReleaseTool {
    
    @discardableResult
    func prepareRelease(_ targets: [Target]) -> Bool {
        self.adapterService.targets = targets.filter { $0.spec.isAdapter }
        self.sdkService.targets = targets.filter { !$0.spec.isAdapter }
        
        return
            self.sdkService.release() &&
            self.adapterService.release()
    }
}



