//
//  File.swift
//  
//
//  Created by Paul Calnan on 5/24/20.
//

import DocSpellFramework
import Foundation
import XCTest

class WhitelistTests: XCTestCase {

    func testNil() throws {
        XCTAssertNil(try Whitelist.load(fromFile: nil))
    }

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
