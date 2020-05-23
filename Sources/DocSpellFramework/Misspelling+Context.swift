//
//  Misspelling+Context.swift
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

import Foundation

public extension Misspelling {

    struct Context {

        var sourceLine: String

        var highlightLine: String
    }

    func context(maxLineLength: Int?) -> Context {
        let result = Misspelling.context(for: range, in: docComment as NSString, maxLineLength: maxLineLength)
        return Context(sourceLine: result.line, highlightLine: result.highlight)
    }

    private static func context(for misspellingRange: NSRange,
                                in string: NSString,
                                maxLineLength: Int?) -> (line: String, highlight: String) {

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
        let maxLineLength = maxLineLength ?? 0
        if maxLineLength > 0, fullLine.length > maxLineLength {

            // Is our highlight beyond the end of the first line?
            if highlightLeading + highlightLength > maxLineLength {
                // Chop off the front to keep the highlight on the first line.
                let leading = (highlightLeading + highlightLength + 1) - (maxLineLength / 2)
                fullLine = fullLine.substring(from: min(leading, fullLine.length)) as NSString
                highlight = highlight.substring(from: min(leading, highlight.length)) as NSString

                // Chop off the end to fit it all on one line
                fullLine = fullLine.substring(to: min(maxLineLength, fullLine.length)) as NSString
                highlight = highlight.substring(to: min(maxLineLength, highlight.length)) as NSString
            }
            else {
                // Just chop off the end of the strings.
                return (fullLine.substring(to: min(maxLineLength, fullLine.length - 1)),
                        highlight.substring(to: min(maxLineLength, highlight.length - 1)))
            }
        }

        return (fullLine as String, highlight as String)
    }
}
