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

    // If we are running in the terminal, this will return the size of the window.
    private func windowSize() -> (columns: Int, rows: Int) {
        var w = winsize()
        _ = ioctl(STDOUT_FILENO, TIOCGWINSZ, &w)
        return (columns: Int(w.ws_col), rows: Int(w.ws_row))
    }

    func run() {
        module.docs.forEach {
            print($0)
            spellCheck(Element(dictionary: $0.docsDictionary).findDocumentation())
            print("--------------------------------------------------------------------------------")
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

                let context = self.context(for: range, in: comment as NSString)
                print(context.line)
                print(context.highlight)
            }
        }
    }

    private func context(for misspellingRange: NSRange, in string: NSString) -> (line: String, highlight: String) {
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

        // Construct the full line containing the misspelling.
        let rangeOfLine = NSRange(location: startOfLine, length: locationOfNextNewline - startOfLine)
        var fullLine = string.substring(with: rangeOfLine) as NSString

        // Construct a highlight line to underline the misspelling (e.g., ^~~~~~)
        let highlightLeading = misspellingRange.location - rangeOfLine.location
        let highlightLength = misspellingRange.length
        var highlight = [String(repeating: " ", count: highlightLeading), "^", String(repeating: "~", count: highlightLength - 1)].joined() as NSString

        // If our line is longer than the width of the window...
        let windowWidth = windowSize().columns
        if windowWidth > 0, fullLine.length > windowWidth {

            // Is our highlight beyond the end of the first line?
            if highlightLeading + highlightLength > windowWidth {
                // Chop off the front to keep the highlight on the first line.
                let leading = (highlightLeading + highlightLength + 1) - (windowWidth / 2)
                fullLine = fullLine.substring(from: min(leading, fullLine.length)) as NSString
                highlight = highlight.substring(from: min(leading, highlight.length)) as NSString

                // Chop off the end to fit it all on one line
                fullLine = fullLine.substring(to: min(windowWidth, fullLine.length)) as NSString
                highlight = highlight.substring(to: min(windowWidth, highlight.length)) as NSString
            }
            else {
                // Just chop off the end of the strings.
                return (fullLine.substring(to: min(windowWidth, fullLine.length - 1)), highlight.substring(to: min(windowWidth, highlight.length - 1)))
            }
        }

        return (fullLine as String, highlight as String)
    }
}
