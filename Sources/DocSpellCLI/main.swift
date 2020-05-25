//
//  main.swift
//  DocSpellCLI
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
import DocSpellFramework
import Foundation

// MARK: - Subcommand

/// Required data provided by subcommands.
protocol Subcommand {

    /// The input passed to the spell checker.
    var input: Input { get }

    /// The options for this subcommand.
    var options: Options { get }
}

/// All subcommands defined here conform to the `ParsableCommand` protocol.
extension Subcommand where Self: ParsableCommand {

    /// After a subcommand is parsed, this function is called.
    func run() throws {
        try DocSpell.run(self)
    }
}

// MARK: - Options

/// Options provided by all subcommands.
struct Options: ParsableArguments {

    @Option(name: .shortAndLong,
            default: nil,
            help: "Whitelist file (must have .plist or .json extension)")
    var whitelist: String?
}

// MARK: - swift-package subcommand

struct SwiftPackage: Subcommand, ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Runs the spell checker on the specified Swift package.")

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

    var input: Input {
        .swiftPackage(name: name, path: path, arguments: arguments)
    }
}

// MARK: - xcode-build subcommand

struct XcodeBuild: Subcommand, ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Runs the spell checker on an Xcode project.")

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

    var input: Input {
        .xcodeBuild(name: name, path: path, arguments: arguments)
    }

    @OptionGroup()
    var options: Options
}

// MARK: - single-files subcommand

struct SingleFiles: Subcommand, ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Runs the spell checker on individual Swift source files.")

    @Argument(help: "The files to check.")
    var filenames: [String]

    var input: Input {
        .singleFiles(filenames: filenames)
    }

    @OptionGroup()
    var options: Options
}

// MARK: - Main command

struct DocSpell: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "DocSpell",
        abstract: "Spell check inline documentation",
        subcommands: [SwiftPackage.self, XcodeBuild.self, SingleFiles.self])

    /// A subcommand, when parsed, calls this function passing passing itself.
    static func run(_ command: Subcommand) throws {

        let spellChecker = SpellChecker(
            input: command.input,
            whitelist: try Whitelist.load(fromFile: command.options.whitelist))

        let misspellings = try spellChecker.run()
        let output = misspellings.map { $0.message() }
        print(output.joined(separator: "\n"))
    }
}

// Entry point
DocSpell.main()
