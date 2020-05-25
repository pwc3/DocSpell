//
//  Input.swift
//  DocSpellFramework
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

import Foundation
import SourceKittenFramework

/// Input to the spell checker.
public enum Input {

    /// Indicates an error related to the spell checker inputs.
    public enum InputError: Error {

        /// Unable to generate a `SwiftDocs` object from the input.
        case docFailed

        /// Unable to read the input file.
        case readFailed(path: String)
    }

    /// Builds a Swift Package Manager project and uses its source code as inputs to the spell checker.
    case swiftPackage(name: String?, path: String, arguments: [String])

    /// Builds an Xcode project and uses its source code as inputs to the spell checker.
    case xcodeBuild(name: String?, path: String, arguments: [String])

    /// Uses individual source files as inputs to the spell checker.
    case singleFiles(filenames: [String])

    /// Loads an array of `SwiftDocs` objects corresponding to this input.
    internal func loadDocs() throws -> [SwiftDocs] {
        switch self {

        case .swiftPackage(let name, let path, let arguments):
            return try load(from: Module(spmArguments: arguments, spmName: name, inPath: path))

        case .xcodeBuild(let name, let path, let arguments):
            return try load(from: Module(xcodeBuildArguments: arguments, name: name, inPath: path))

        case .singleFiles(let filenames):
            return try load(from: filenames)
        }
    }

    /// Loads an array of `SwiftDocs` from the specified module.
    ///
    /// - parameter module: An optional module. This will only be `nil` if loading the module failed.
    /// - throws: `InputError.docFailed` if the module is `nil`.
    private func load(from module: Module?) throws -> [SwiftDocs] {
        guard let docs = module?.docs else {
            throw InputError.docFailed
        }
        return docs
    }

    /// Loads an array of `SwiftDocs` objects from the specified source files.
    ///
    /// - parameter filenames: An array of source file paths.
    /// - throws: `InputError.readFailed` if any of the source files cannot be read.
    /// - throws: `InputError.docFailed` if the documentation cannot be loaded from any of the source files.
    private func load(from filenames: [String]) throws -> [SwiftDocs] {
        return try filenames.map { filename in
            guard let file = File(path: filename) else {
                throw InputError.readFailed(path: filename)
            }

            guard let docs = SwiftDocs(file: file, arguments: []) else {
                throw InputError.docFailed
            }

            return docs
        }
    }
}

extension Input: CustomStringConvertible {

    public var description: String {
        switch self {
        case .swiftPackage(let name, let path, _):
            return "Swift package \(name ?? "(nil)") at \(path)"

        case .xcodeBuild(let name, let path, _):
            return "Xcode build of \(name ?? "(nil)") at \(path)"

        case .singleFiles(let filenames):
            return "Single files: \(filenames.joined(separator: ", "))"
        }
    }
}
