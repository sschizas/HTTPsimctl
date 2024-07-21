//
//  VersionCommand.swift
//
//  Created by Stavros Schizas on 22/7/23.
//

import Vapor

public struct VersionCommand: Command {
    public struct Signature: CommandSignature {
        public init() {}
    }
    
    public var help: String {
        "Display the current version of HTTPsimctl."
    }
    
    public init() {}
    
    public func run(using context: CommandContext, signature: Signature) throws {
        context.console.print("HTTPsimctl v1.5.0")
    }
}
