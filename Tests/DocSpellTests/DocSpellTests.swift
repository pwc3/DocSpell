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

        let misspellings = try spellChecker.run().get()

        XCTAssertEqual(misspellings, [
            Misspelling(word: "strng",    file: path, line: 28, column: 31),
            Misspelling(word: "mispelng", file: path, line: 31, column: 56),
            Misspelling(word: "cntans",   file: path, line: 32, column: 35),
            Misspelling(word: "mispelng", file: path, line: 32, column: 46)
        ])
    }
}
