//
//  SpellChecker+Input.swift
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

public extension SpellChecker {

    enum Input {

        case swiftPackage(name: String?, path: String, arguments: [String])

        case xcodeBuild(name: String?, path: String, arguments: [String])

        case singleFiles(filenames: [String])

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

        private func load(from module: Module?) throws -> [SwiftDocs] {
            guard let docs = module?.docs else {
                throw DocSpellError.docFailed
            }
            return docs
        }

        private func load(from filenames: [String]) throws -> [SwiftDocs] {
            return try filenames.map { filename in
                guard let file = File(path: filename) else {
                    throw DocSpellError.readFailed(path: filename)
                }

                guard let docs = SwiftDocs(file: file, arguments: []) else {
                    throw DocSpellError.docFailed
                }

                return docs
            }
        }
    }
}
