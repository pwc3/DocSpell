//
//  Whitelist.swift
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

/// Defines a list of words that are ignored when detected as misspellings by the spell checker.
public struct Whitelist: Codable {

    /// Indicates a whitelist error.
    public enum WhitelistError: Error {

        /// Indicates that a filename with an invalid extension was provided.
        case invalidExtension
    }

    /// The whitelisted words.
    public var words: [String]

    /// Creates a new whitelist with the specified words.
    public init(words: [String]) {
        self.words = words
    }

    /// Returns `true` if the specified word is contained in the whitelist, `false` otherwise. Note that the whitelist
    /// is case-insensitive.
    public func contains(_ word: String) -> Bool {
        return words.first(where: {
            $0.compare(word, options: .caseInsensitive) == .orderedSame
        }) != nil
    }

    /// Loads the whitelist at the specified path. Returns `nil` if a `nil` path is provided. Note that the filename
    /// must end in `.json` or `.plist`. This is used to determine the format of the whitelist file.
    ///
    /// This function converts the path to a `URL` and passes it to the `load(from:)` function.
    ///
    /// - parameter path: The path of the whitelist file.
    /// - returns: A whitelist object read from the specified file.
    public static func load(fromFile path: String?) throws -> Whitelist? {
        return try path.flatMap { try load(from: URL(fileURLWithPath: $0)) }
    }

    /// Loads the whitelist at the specified URL. Note that the URL's path extension must end in `.json` or `.plist`.
    /// This is used to determine the format of the whitelist file.
    ///
    /// - parameter url: The URL of the whitelist file.
    /// - returns: A `Whitelist` instance read from the specified file.
    public static func load(from url: URL) throws -> Whitelist {
        switch url.pathExtension.lowercased() {
        case "json":
            return try JSONDecoder().decode(Whitelist.self, from: try Data(contentsOf: url))

        case "plist":
            return try PropertyListDecoder().decode(Whitelist.self, from: try Data(contentsOf: url))

        default:
            throw WhitelistError.invalidExtension
        }
    }
}
