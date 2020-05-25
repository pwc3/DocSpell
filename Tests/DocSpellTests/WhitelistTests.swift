//
//  WhitelistTests.swift
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

import DocSpellFramework
import Foundation
import XCTest

class WhitelistTests: XCTestCase {

    /// Verifies that passing a `nil` filename results in a `nil` `Whitelist` instance.
    func testNil() throws {
        XCTAssertNil(try Whitelist.load(fromFile: nil))
    }

    /// Verifies loading a `Whitelist` instance from a property list file.
    func testLoadPlist() throws {
        guard let whitelist = try Whitelist.load(fromFile: Fixture.path(for: "SampleWhitelist.plist")) else {
            XCTFail("Unexpected nil value")
            return
        }

        XCTAssertEqual(whitelist.words, ["foo", "bar", "baz"])

        XCTAssertTrue(whitelist.contains("FOO"))
        XCTAssertTrue(whitelist.contains("bAr"))
        XCTAssertTrue(whitelist.contains("baZ"))
        XCTAssertFalse(whitelist.contains("fnord"))
    }

    /// Verifies loading a `Whitelist` instance from a JSON file.
    func testLoadJson() throws {
        guard let whitelist = try Whitelist.load(fromFile: Fixture.path(for: "SampleWhitelist.json")) else {
            XCTFail("Unexpected nil value")
            return
        }

        XCTAssertEqual(whitelist.words, ["foo", "bar", "baz"])

        XCTAssertTrue(whitelist.contains("FOO"))
        XCTAssertTrue(whitelist.contains("bAr"))
        XCTAssertTrue(whitelist.contains("baZ"))
        XCTAssertFalse(whitelist.contains("fnord"))
    }
}
