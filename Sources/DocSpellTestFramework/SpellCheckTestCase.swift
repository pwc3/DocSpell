//
//  SpellCheckTestCase.swift
//  DocSpellTestFramework
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

/// A test case to run the spell checker as part of a unit test. Emits test failures for each misspelling.
open class SpellCheckTestCase: XCTestCase {

    /// Spell check the documentation for the specified input.
    public final func spellCheckDocumentation(_ input: Input, whitelist: Whitelist? = nil) throws {
        print("Spell checking \(input)")
        let spellChecker = SpellChecker(input: input, whitelist: whitelist)

        let misspellings = try spellChecker.run()
        for misspelling in misspellings {
            recordFailure(withDescription: misspelling.word,
                          inFile: misspelling.file,
                          atLine: Int(misspelling.line),
                          expected: true)
        }
    }
}
