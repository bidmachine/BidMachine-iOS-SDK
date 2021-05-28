#!/usr/bin/swift sh

import Foundation
import Services // ./Services/

OptionParserService.parseOptions(CommandLine.arguments)

//
//
//let build = XCBuild("/Users/assassinsc/Desktop/BidMachine-iOS-SDK/BidMachine.xcworkspace", "BidMachine")
//let result = build.build("arm64 armv7")
////let result = build.build("i386")
//
////shell("`\(result.decription) | xcpretty > /Users/assassinsc/Desktop/Release/log.log`")
////shell("echo ; \(result.decription) ; >> ; /Users/assassinsc/Desktop/Release/log.log")
////shell(result.decription)
//print("code = \(result.code)")
////print(result.decription)
//
//Logging.printf("/Users/assassinsc/Desktop/Release/log.log", result.desription)


