//
//  IssueLocator.swift
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
import SourceKittenFramework

import AppKit

class IssueLocator {

    enum IssueLocatorError: Error {
        case encodingError
    }

    private let file: String

    private let misspellings: [Misspelling]

    private let spellChecker: NSSpellChecker

    init(file: String, misspellings: [Misspelling]) {
        self.file = file
        self.misspellings = misspellings

        spellChecker = NSSpellChecker.shared
        spellChecker.setLanguage("en")
    }

    func run() -> Result<[Issue], Error> {
        return Result(catching: { try _run() })
    }

    private func _run() throws -> [Issue] {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: file))
        guard let fileString =  String(data: fileData, encoding: .utf8) else {
            throw IssueLocatorError.encodingError
        }
        let view = StringView(fileString)

        return try misspellings.map {
            try resolve(misspelling: $0, in: view)
        }
    }

    // TODO: Move this to the SpellChecker class
    private func resolve(misspelling: Misspelling, in view: StringView) throws -> Issue {

        let rawDocCommentString = view.substringWithByteRange(misspelling.byteRange)!
        let rawDocCommentStringView = StringView(rawDocCommentString)

        // misspelling.range is the character range of the misspelling in docComment
        // we want to convert that to the byte range in docCommentData.

        // let docCommentString = misspelling.docComment

        let types: NSTextCheckingResult.CheckingType = [.spelling]
        let results = spellChecker.check(rawDocCommentString,
                                         range: NSRange(location: 0, length: rawDocCommentString.count),
                                         types: types.rawValue,
                                         options: [.orthography: NSOrthography.defaultOrthography(forLanguage: "en")],
                                         inSpellDocumentWithTag: 0,
                                         orthography: nil,
                                         wordCount: nil)
        results.forEach { result in
            print("Found \(result.numberOfRanges) misspelling(s)")

            (0..<result.numberOfRanges).forEach { index in
                let range = result.range(at: index)
                let found = (rawDocCommentString as NSString).substring(with: range)
                print("Misspelling \(index): \(found)")

                let byteRangeOfMisspellingInDocComment = rawDocCommentStringView.NSRangeToByteRange(range)!
                let byteOffsetOfMisspellingInFile = misspelling.byteRange.location + byteRangeOfMisspellingInDocComment.location

                let location = view.lineAndCharacter(forByteOffset: byteOffsetOfMisspellingInFile)!
                print("Line: \(location.line), Column: \(location.character), Length: \(range.length)")
            }
        }

        return Issue(misspelling: "", line: 0, column: 0)
    }
}
