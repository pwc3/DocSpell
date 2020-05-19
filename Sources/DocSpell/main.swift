//
//  main.swift
//  DocSpell
//
//  Copyright (c) 2020 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import ArgumentParser
import Foundation
import SourceKittenFramework

protocol DocSpellCommand {

    func loadModule() -> Module?

    var options: DocSpell.Options { get }
}

struct DocSpell: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Spell check inline documentation",
        subcommands: [SwiftPackage.self, XcodeBuild.self])

    static func run(_ command: DocSpellCommand) {
        run(module: command.loadModule(), verbose: command.options.verbose)
    }

    static func run(module: Module?, verbose: Bool) {
        guard let module = module else {
            print("Could not build module", to: &stderr)
            return
        }

        let op = SpellCheckOperation(module: module)
        print(SpellCheckResultFormatter.format(results: op.run()).joined(separator: "\n"))
    }

    struct Options: ParsableArguments {
        @Flag(name: .shortAndLong, help: "Show verbose output.")
        var verbose: Bool
    }

    struct SwiftPackage: ParsableCommand, DocSpellCommand {

        @Option(name: .shortAndLong,
                default: nil,
                help: "Module name. Will use some non-Test module that is part of the package if not specified.")
        var name: String?

        @Option(name: .shortAndLong,
                default: FileManager.default.currentDirectoryPath,
                help: "Path of the directory containing the Package.swift file.")
        var path: String

        @Argument(help: "Additional arguments to pass to `swift build`.")
        var arguments: [String]

        @OptionGroup()
        var options: Options

        func loadModule() -> Module? {
            Module(spmArguments: arguments, spmName: name, inPath: path)
        }

        func run() {
            DocSpell.run(self)
        }
    }

    struct XcodeBuild: ParsableCommand, DocSpellCommand {

        @Option(name: .shortAndLong,
                default: nil,
                help: "Module name. Will be parsed from `xcodebuild` output if not specified.")
        var name: String?

        @Option(name: .shortAndLong,
                default: FileManager.default.currentDirectoryPath,
                help: "Path to run `xcodebuild` from.")
        var path: String

        @Argument(help: "The arguments necessary to pass in to `xcodebuild` to build this module.")
        var arguments: [String]

        @OptionGroup()
        var options: Options

        func loadModule() -> Module? {
            Module(xcodeBuildArguments: arguments, name: name, inPath: path)
        }

        func run() {
            DocSpell.run(self)
        }
    }
}

DocSpell.main()
