import ArgumentParser
import Foundation
import SourceKittenFramework

struct DocSpell: ParsableCommand {

    static var configuration = CommandConfiguration(
        abstract: "Spell check inline documentation",
        subcommands: [SwiftPackage.self, XcodeBuild.self])

    static func run(module: Module?) {
        guard let module = module else {
            print("Could not build module", to: &stderr)
            return
        }

        let op = SpellCheckOperation(module: module)
        op.run()
    }
}

extension DocSpell {
    struct SwiftPackage: ParsableCommand {

        @Option(default: nil,
                help: "Module name. Will use some non-Test module that is part of the package if not specified.")
        var name: String?

        @Option(default: FileManager.default.currentDirectoryPath,
                help: "Path of the directory containing the Package.swift file. Uses the current directory by default.")
        var path: String

        @Argument(help: "Additional arguments to pass to `swift build`.")
        var arguments: [String]

        func run() {
            DocSpell.run(module: Module(spmArguments: arguments, spmName: name, inPath: path))
        }
    }
}

extension DocSpell {
    struct XcodeBuild: ParsableCommand {

        @Option(default: nil,
                help: "Module name. Will be parsed from `xcodebuild` output if not specified.")
        var name: String?

        @Option(default: FileManager.default.currentDirectoryPath,
                help: "Path to run `xcodebuild` from. Uses the current directory by default.")
        var path: String

        @Argument(help: "The arguments necessary to pass in to `xcodebuild` to build this module.")
        var arguments: [String]

        func run() {
            DocSpell.run(module: Module(xcodeBuildArguments: arguments, name: name, inPath: path))
        }
    }
}

DocSpell.main()
