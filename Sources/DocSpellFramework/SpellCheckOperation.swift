//
//  SpellCheckOperation.swift
//  DocSpell
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

import AppKit
import Foundation
import SourceKittenFramework

public class SpellCheckOperation {

    private let docs: [SwiftDocs]

    private let spellChecker: NSSpellChecker

    public init(docs: [SwiftDocs]) {
        self.docs = docs

        spellChecker = NSSpellChecker.shared
        spellChecker.setLanguage("en")
    }

    public func run() -> [SpellCheckResult] {
        docs.map { doc -> SpellCheckResult in
            SpellCheckResult(docs: doc, misspellings: spellCheck(Element(dictionary: doc.docsDictionary).findDocumentation()))
        }
    }

    func spellCheck(_ documentation: [Element]) -> [Misspelling] {
        documentation.flatMap {
            spellCheck($0)
        }
    }

    func spellCheck(_ documentation: Element) -> [Misspelling] {
        guard
            let symbol = documentation.docName,
            let file = documentation.docFile,
            let symbolLine = documentation.docLine,
            let symbolColumn = documentation.docColumn,
            let docComment = documentation.documentationComment,
            let docOffset = documentation.docOffset,
            let docLength = documentation.docLength
        else {
            return []
        }

        let types: NSTextCheckingResult.CheckingType = [.spelling]
        let results = spellChecker.check(docComment,
                                         range: NSRange(location: 0, length: docComment.count),
                                         types: types.rawValue,
                                         options: [.orthography: NSOrthography.defaultOrthography(forLanguage: "en")],
                                         inSpellDocumentWithTag: 0,
                                         orthography: nil,
                                         wordCount: nil)

        return results.flatMap { result -> [Misspelling] in
            guard result.resultType == .spelling else {
                return []
            }

            return (0..<result.numberOfRanges).map { i -> Misspelling in
                return Misspelling(symbol: symbol,
                                   file: file,
                                   symbolLine: symbolLine,
                                   symbolColumn: symbolColumn,
                                   docComment: docComment,
                                   docOffset: docOffset,
                                   docLength: docLength,
                                   range: result.range(at: i))
            }
        }
    }
}
