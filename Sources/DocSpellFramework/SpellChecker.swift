//
//  SpellChecker.swift
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

import AppKit
import Foundation
import SourceKittenFramework

public class SpellChecker {

    enum SpellCheckerError: Error {
        case encodingError
        case noFilePath
        case missingData
        case internalError
    }

    private let input: Input

    private let whitelist: Whitelist?

    private let spellChecker: NSSpellChecker

    public init(input: Input, whitelist: Whitelist? = nil) {
        self.input = input
        self.whitelist = whitelist

        spellChecker = NSSpellChecker.shared
        spellChecker.setLanguage("en")
    }

    public func run() -> Result<[Misspelling], Error> {
        return Result(catching: {
            try input.loadDocs().flatMap {
                try spellCheck(docs: $0)
            }
        })
    }

    private func spellCheck(docs: SwiftDocs) throws -> [Misspelling] {
        guard let path = docs.file.path else {
            throw SpellCheckerError.noFilePath
        }

        let elements = Element(dictionary: docs.docsDictionary).findDocumentation()
        return try spellCheck(elements: elements, inFileAtPath: path)
    }

    private func spellCheck(elements: [Element], inFileAtPath path: String) throws -> [Misspelling] {
        let fileData = try Data(contentsOf: URL(fileURLWithPath: path))
        guard let fileString =  String(data: fileData, encoding: .utf8) else {
            throw SpellCheckerError.encodingError
        }
        return try spellCheck(elements: elements, inView: StringView(fileString), ofFileAtPath: path)
    }

    private func spellCheck(elements: [Element], inView view: StringView, ofFileAtPath filePath: String) throws -> [Misspelling] {
        return try elements.flatMap {
            try spellCheck(element: $0, inView: view, ofFileAtPath: filePath)
        }
    }

    private func spellCheck(element: Element, inView fileView: StringView, ofFileAtPath filePath: String) throws -> [Misspelling] {
        // SourceKit reports the byte range of the doc comment in the source file
        guard let docCommentByteRangeInSourceFile = element.docCommentByteRange else {
            throw SpellCheckerError.missingData
        }

        // Get the full doc comment from the source file.
        guard let docComment = fileView.substringWithByteRange(docCommentByteRangeInSourceFile) else {
            throw SpellCheckerError.internalError
        }

        // Make a StringView of the full doc comment to convert from NSRange to a byte range.
        let docCommentView = StringView(docComment)

        // Spell check the full doc comment.
        let types: NSTextCheckingResult.CheckingType = [.spelling]
        let results = spellChecker.check(docComment,
                                         range: NSRange(location: 0, length: docComment.count),
                                         types: types.rawValue,
                                         options: [.orthography: NSOrthography.defaultOrthography(forLanguage: "en")],
                                         inSpellDocumentWithTag: 0,
                                         orthography: nil,
                                         wordCount: nil)

        return results.flatMap { result in
            return (0..<result.numberOfRanges).compactMap { index -> Misspelling? in
                // The range of the misspelling.
                let range = result.range(at: index)

                // The misspelled word.
                let misspelling = (docComment as NSString).substring(with: range)

                // Ignore whitelisted words
                if whitelist?.contains(misspelling) == true {
                    return nil
                }

                // The byte range of the misspelling in the doc comment.
                guard let misspellingByteRangeInDocComment = docCommentView.NSRangeToByteRange(range) else {
                    return nil
                }

                // The byte offset of the misspelling in the file is:
                let byteOffsetOfMisspellingInFile =
                    // The offset of the doc comment in the source file, plus...
                    docCommentByteRangeInSourceFile.location +
                    // ...the offset of the misspelling in the doc comment
                    misspellingByteRangeInDocComment.location

                // Use the file view to translate the byte offset into line and column.
                guard let location = fileView.lineAndCharacter(forByteOffset: byteOffsetOfMisspellingInFile) else {
                    return nil
                }

                return Misspelling(word: misspelling,
                                   file: filePath,
                                   line: UInt(location.line),
                                   column: UInt(location.character))
            }
        }
    }
}
