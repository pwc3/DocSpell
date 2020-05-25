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
import SourceKittenFramework

/// Provides information about a misspelling found by the spell checker.
public struct Misspelling: Equatable {

    /// The misspelled word.
    public var word: String

    /// The path of the source file containing the misspelling.
    public var file: String

    /// The number of the line in the source file containing the misspelling.
    public var line: UInt

    /// The column of the line in the source file indicating the start of the misspelling.
    public var column: UInt

    /// Creates a new `Misspelling` instance.
    init(word: String, file: String, line: UInt, column: UInt) {
        self.word = word
        self.file = file
        self.line = line
        self.column = column
    }
}

extension Misspelling {

    /// Indicates the severity of a message.
    public enum Severity: String {

        /// A warning message.
        case warning

        /// An error message.
        case error
    }

    /// Returns a string, suitable for printing, indicating the location, severity, and misspelling.
    /// The format is recognized by Xcode when emitted as part of a Run Script Build Phase, allowing users to select a
    /// message and see the the misspelled word in its source file.
    ///
    /// - parameter severity: The severity of the message.
    /// - returns: The message string for this misspelling.
    public func message(_ severity: Severity = .warning) -> String {
        return "\(file):\(line):\(column): \(severity): \(word)"
    }
}
