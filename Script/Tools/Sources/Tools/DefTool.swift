import Foundation

public
struct Scheme {
    static let release = "BidMachine"
}

public
struct Paths {
    static let workspace = "BidMachine.xcworkspace"
    static let frameworks = "BidMachineRelease/Frameworks"
    static let build = "BidMachineRelease/build"
}

public
enum BuildType: String {
    case iphonesimulator
    case iphoneos
    case universal
}

public
enum Frameworks: String {
    case BidMachine
    case StackAPI
    case BDMAdColonyAdapter
    case BDMAmazonAdapter
    case BDMAppRollAdapter
    case BDMCriteoAdapter
    case BDMFacebookAdapter
    case BDMMyTargetAdapter
    case BDMSmaatoAdapter
    case BDMTapjoyAdapter
    case BDMVungleAdapter
    case BDMMRAIDAdapter
    case BDMVASTAdapter
    case BDMNASTAdapter
    case BDMIABAdapter
}

let requiredFrameworks: [Frameworks] = [.BidMachine,
                                        .StackAPI]

let requiredLibs: [Frameworks] = [.BDMAdColonyAdapter,
                                  .BDMAmazonAdapter,
                                  .BDMAppRollAdapter,
                                  .BDMCriteoAdapter,
                                  .BDMFacebookAdapter,
                                  .BDMMyTargetAdapter,
                                  .BDMSmaatoAdapter,
                                  .BDMTapjoyAdapter,
                                  .BDMVungleAdapter,
                                  .BDMMRAIDAdapter, .BDMNASTAdapter, .BDMVASTAdapter]

let mergingMap: [Frameworks : [Frameworks]] = [.BidMachine : [.BidMachine, .StackAPI],
                                               .BDMIABAdapter : [.BDMMRAIDAdapter, .BDMVASTAdapter, .BDMNASTAdapter]]
