//
//  Fixture.swift
//  DocSpellTests
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

/// Utility for accessing test fixtures in this directory.
struct Fixture {

    /// The URL of the `Fixtures` directory (i.e., this file's parent directory).
    static var directory: URL {
        URL(fileURLWithPath: #file).deletingLastPathComponent()
    }

    /// Returns the URL for the fixture file with the specified name.
    static func url(for name: String) -> URL {
        return directory.appendingPathComponent(name)
    }

    /// Returns the path for the fixture file with the specified name.
    static func path(for name: String) -> String {
        return url(for: name).path
    }

    /// Returns the String contents of the specified fixture file.
    static func contents(ofFile name: String) throws -> String {
        return try String(contentsOf: url(for: name))
    }
}
