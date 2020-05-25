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

    /// Tests reading a test fixture file.
    func testReadFixture() {
        XCTAssertNoThrow(try Fixture.contents(ofFile: "TestFile1.swift"))
    }

    /// Runs the spell checker on the `TestFile1.swift` test fixture.
    func testCheckSpellingOfFixture() throws {
        let path = Fixture.path(for: "TestFile1.swift")
        let spellChecker = SpellChecker(input: .singleFiles(filenames: [path]), whitelist: Whitelist(words: ["whargarbl"]))

        let misspellings = try spellChecker.run()

        XCTAssertEqual(misspellings.count, 11)
        check(misspellings, at:  0, isEqualTo: Misspelling(word: "strng",     file: path, line: 28, column: 31))
        check(misspellings, at:  1, isEqualTo: Misspelling(word: "mispelng",  file: path, line: 31, column: 56))
        check(misspellings, at:  2, isEqualTo: Misspelling(word: "cntans",    file: path, line: 32, column: 35))
        check(misspellings, at:  3, isEqualTo: Misspelling(word: "mispelngs", file: path, line: 32, column: 46))
        check(misspellings, at:  4, isEqualTo: Misspelling(word: "commnt",    file: path, line: 36, column: 56))
        check(misspellings, at:  5, isEqualTo: Misspelling(word: "stle",      file: path, line: 36, column: 63))
        check(misspellings, at:  6, isEqualTo: Misspelling(word: "mspelngs",  file: path, line: 37, column: 20))
        check(misspellings, at:  7, isEqualTo: Misspelling(word: "prvous",    file: path, line: 37, column: 36))
        check(misspellings, at:  8, isEqualTo: Misspelling(word: "astrsks",   file: path, line: 42, column: 45))
        check(misspellings, at:  9, isEqualTo: Misspelling(word: "strt",      file: path, line: 42, column: 60))
        check(misspellings, at: 10, isEqualTo: Misspelling(word: "oth",       file: path, line: 43, column: 34))
    }

    /// Utility to check misspellings. Checks that the misspelling at the specified index exists and is equal to the
    /// expected misspelling. The file and line number of the call site are captured so failures are emitted from the
    /// call site instead of from this function.
    ///
    /// - parameter actualArray: The array of misspellings returned by the spell checker.
    /// - parameter index: The index, in `actualArray`, of the misspelling being checked.
    /// - parameter expected: The expected misspelling.
    /// - parameter file: The file of the call site.
    /// - parameter line: The line number of the call site.
    private func check(_ actualArray: [Misspelling], at index: Int, isEqualTo expected: Misspelling, file: StaticString = #file, line: UInt = #line) {
        guard index < actualArray.count else {
            XCTFail("Invalid index \(index) >= \(actualArray.count)", file: file, line: line)
            return
        }

        let actual = actualArray[index]
        XCTAssertEqual(expected, actual, file: file, line: line)
    }
}
