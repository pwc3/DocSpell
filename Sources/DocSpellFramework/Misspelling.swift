//
//  Misspelling.swift
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

public struct Misspelling: Codable {

    /// The symbol with the misspelled documentation.
    public var symbol: String

    /// The path of the source file.
    public var file: String

    /// The line number of the declaration with the misspelled documentation.
    public var symbolLine: Int64

    /// The column of the declaration with the misspelled documentation.
    public var symbolColumn: Int64

    /// The body of the documentation comment.
    public var docComment: String

    /// The byte offset in the source file where the documentation comment begins.
    public var docOffset: Int64

    /// The length, in bytes, of the documentation comment in the source file.
    public var docLength: Int64

    /// The range of the misspelling in the `docComment` string.
    public var range: NSRange

    public var misspelling: String {
        return (docComment as NSString).substring(with: range)
    }
}

extension Misspelling: CustomStringConvertible {

    public var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        return String(data: try! encoder.encode(self), encoding: .utf8)!
    }
}
