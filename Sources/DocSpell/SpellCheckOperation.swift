import AppKit
import Foundation
import SourceKittenFramework

class SpellCheckOperation {

    let module: Module

    let spellChecker: NSSpellChecker

    init(module: Module) {
        self.module = module

        spellChecker = NSSpellChecker.shared
        spellChecker.setLanguage("en")
    }

    func run() {
        module.docs.forEach {
            spellCheck(Element(dictionary: $0.docsDictionary).findDocumentation())
        }
    }

    func spellCheck(_ documentation: [Element]) {
        documentation.forEach(spellCheck(_:))
    }

    func spellCheck(_ documentation: Element) {
        guard
            let name = documentation.docName,
            let file = documentation.docFile,
            let line = documentation.docLine,
            let column = documentation.docColumn,
            // let offset = documentation.bestOffset,
            let comment = documentation.documentationComment
        else {
            return
        }

        let types: NSTextCheckingResult.CheckingType = [.spelling]
        let results = spellChecker.check(comment,
                                         range: NSRange(location: 0, length: comment.count),
                                         types: types.rawValue,
                                         options: [.orthography: NSOrthography.defaultOrthography(forLanguage: "en")],
                                         inSpellDocumentWithTag: 0,
                                         orthography: nil,
                                         wordCount: nil)

        results.forEach { result in
            guard result.resultType == .spelling else {
                return
            }

            for i in 0 ..< result.numberOfRanges {
                let range = result.range(at: i)

                let misspelling = (comment as NSString).substring(with: range)
                print("\(file):\(line):\(column): warning: Documentation of \(name) contains misspelling \(misspelling)")

                let (line, highlight) = findLine(containing: range, in: (comment as NSString))
                print(line)
                print(highlight)
            }
        }
    }

    private func findLine(containing misspellingRange: NSRange, in string: NSString) -> (String, String) {
        // Search backward from the beginning of the string up to and including the misspelling for a newline.
        let backwardSearchRange = NSRange(location: 0, length: misspellingRange.location + misspellingRange.length)
        let rangeOfPreviousNewline = string.rangeOfCharacter(from: CharacterSet.newlines, options: .backwards, range: backwardSearchRange)

        // Default the location to 0 if no newline was found.
        let startOfLine =
            rangeOfPreviousNewline.location == NSNotFound
                ? 0
                : (rangeOfPreviousNewline.location + 1)

        // Search from the misspelling to the end of the string for a newline.
        let forwardSearchRange = NSRange(location: misspellingRange.location, length: string.length - misspellingRange.location)
        let rangeOfNextNewline = string.rangeOfCharacter(from: CharacterSet.newlines, options: [], range: forwardSearchRange)

        // Default the location to the end of the string if no newline was found.
        let locationOfNextNewline =
            rangeOfNextNewline.location == NSNotFound
                ? string.length
                : rangeOfNextNewline.location

        let rangeOfLine = NSRange(location: startOfLine, length: locationOfNextNewline - startOfLine)
        let fullLine = string.substring(with: rangeOfLine)

        let leadingSpaces = misspellingRange.location - rangeOfLine.location
        let length = misspellingRange.length

        let highlight = [String(repeating: " ", count: leadingSpaces), "^", String(repeating: "~", count: length - 1)].joined()
        return (fullLine, highlight)
    }
}
