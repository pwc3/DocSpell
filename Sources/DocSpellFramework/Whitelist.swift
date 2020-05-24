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

public struct Whitelist: Codable {

    enum WhitelistError: Error {
        case invalidExtension
    }

    public var words: [String]

    public init(words: [String]) {
        self.words = words
    }

    public func contains(_ word: String) -> Bool {
        return words.first(where: {
            $0.compare(word, options: .caseInsensitive) == .orderedSame
        }) != nil
    }

    public static func load(fromFile path: String?) throws -> Whitelist? {
        return try path.flatMap { try load(from: URL(fileURLWithPath: $0)) }
    }

    public static func load(from url: URL) throws -> Whitelist? {
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
