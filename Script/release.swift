#!/usr/bin/swift sh

import Foundation
import ArgumentParser
import Tools // ./Tools/

struct Build: ParsableCommand {
    @Flag(help: "Verbose log level.")
    var verbose = false

    @Argument(help:
    "The Release value. Can be: [Sdk] or [Adapters]")
    var releaseType: String
    
    mutating func run() throws {
        let router = Router.shared
        router.verbose = verbose
        router.releaseSdk(self.releaseType)
    }
}

Build.main()


