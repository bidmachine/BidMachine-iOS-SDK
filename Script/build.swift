#!/usr/bin/swift sh

import Foundation
import ArgumentParser
import Tools // ./Tools/

struct Build: ParsableCommand {
    @Flag(help: "Verbose log level.")
    var verbose = false

    @Option(help: "Make [pod install] before run build.")
    var podInstall = false
    
    mutating func run() throws {
        let router = Router.shared
        router.verbose = verbose
        router.buildSdk()
    }
}

Build.main()


