//
//  DocSpellTests.swift
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

@testable import DocSpellFramework
import XCTest

class DocSpellTests: XCTestCase {
    func testReadFixture() {
        XCTAssertNoThrow(try Fixture.contents(of: "TestFile1.swift"))
    }

    func testDocFixture() throws {
        let path = Fixture.path(for: "TestFile1.swift")
        let spellChecker = SpellChecker(input: .singleFiles(filenames: [path]))

        let results = try spellChecker.run().get()

        // One result, meaning one file had misspellings
        guard results.count == 1, let result = results.first else {
            XCTFail("Incorrect number of results, expected 1, got \(results.count)")
            return
        }

        guard result.misspellings.count == 3 else {
            XCTFail("Incorrect number of misspellings found, expected 3, got \(result.misspellings.count)")
            return
        }

        XCTAssertEqual(result.misspellings[0].misspelling, "strng")
        XCTAssertEqual(result.misspellings[1].misspelling, "mispelng")
        XCTAssertEqual(result.misspellings[2].misspelling, "mispelng")
    }
}
