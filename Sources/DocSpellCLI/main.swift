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
import DocSpellFramework
import Foundation
import SourceKittenFramework

protocol DocSpellCommand {

    func loadDocs() -> Result<[SwiftDocs], DocSpellError>

    var options: DocSpell.Options { get }
}

enum DocSpellError: Error, CustomStringConvertible {

    case docFailed

    case readFailed(path: String)

    var description: String {
        switch self {
        case .docFailed:
            return "Unable to generate documentation"

        case .readFailed(let path):
            return "Unable to read file at \"\(path)\""
        }
    }
}

struct DocSpell: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "DocSpell",
        abstract: "Spell check inline documentation",
        subcommands: [SwiftPackage.self, XcodeBuild.self, SingleFiles.self])

    @discardableResult
    static func run(_ command: DocSpellCommand) -> Result<[SpellCheckResult], DocSpellError> {
        switch command.loadDocs() {
        case .success(let docs):
            return .success(run(docs: docs, verbose: command.options.verbose))

        case .failure(let error):
            fputs("Error: \(error)", stderr)
            return .failure(error)
        }
    }

    @discardableResult
    static func run(docs: [SwiftDocs], verbose: Bool) -> [SpellCheckResult] {
        let op = SpellCheckOperation(docs: docs)
        let results = op.run()

        print(SpellCheckResultFormatter.format(results: results, verbose: verbose).joined(separator: "\n"))
        return results
    }
}

extension DocSpell {

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

        @OptionGroup()
        var options: Options

        @Argument(help: "Additional arguments to pass to `swift build`.")
        var arguments: [String]

        func loadDocs() -> Result<[SwiftDocs], DocSpellError> {
            guard let module = Module(spmArguments: arguments, spmName: name, inPath: path) else {
                return .failure(.docFailed)
            }
            return .success(module.docs)
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

        @OptionGroup()
        var options: Options

        @Argument(help: "The arguments necessary to pass in to `xcodebuild` to build this module.")
        var arguments: [String]

        func loadDocs() -> Result<[SwiftDocs], DocSpellError> {
            guard let module = Module(xcodeBuildArguments: arguments, name: name, inPath: path) else {
                return .failure(.docFailed)
            }
            return .success(module.docs)
        }

        func run() {
            DocSpell.run(self)
        }
    }

    struct SingleFiles: ParsableCommand, DocSpellCommand {

        @OptionGroup()
        var options: Options

        @Argument(help: "The files to check.")
        var arguments: [String]

        static func create(arguments: [String]) -> SingleFiles {
            var value = SingleFiles()
            value.arguments = arguments
            return value
        }

        func loadDocs() -> Result<[SwiftDocs], DocSpellError> {
            return Result(catching: { try _loadDocs() }).mapError({ $0 as! DocSpellError })
        }

        private func _loadDocs() throws -> [SwiftDocs] {
            return try arguments.map { filename in
                guard let file = File(path: filename) else {
                    throw DocSpellError.readFailed(path: filename)
                }

                guard let docs = SwiftDocs(file: file, arguments: []) else {
                    throw DocSpellError.docFailed
                }

                return docs
            }
        }

        func run() {
            DocSpell.run(self)
        }
    }
}

DocSpell.main()
