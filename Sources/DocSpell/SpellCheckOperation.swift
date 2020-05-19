import AppKit
import Foundation
import SourceKittenFramework

class SpellCheckOperation {

    let module: Module

    private let spellChecker: NSSpellChecker

    init(module: Module) {
        self.module = module

        spellChecker = NSSpellChecker.shared
        spellChecker.setLanguage("en")
    }

    func run() -> [SpellCheckResult] {
        module.docs.map { doc -> SpellCheckResult in
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
