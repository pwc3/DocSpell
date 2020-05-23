//
//  SpellCheckResultFormatter.swift
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

public struct SpellCheckResultFormatter {

    public static func format(results: [SpellCheckResult], verbose: Bool) -> [String] {
        return results.flatMap {
            return format(result: $0, verbose: verbose)
        }
    }

    private static func format(result: SpellCheckResult, verbose: Bool) -> [String] {
        if result.misspellings.isEmpty {
            return []
        }

        let prefix: [String] =
            verbose
                ? [result.docs.description]
                : []

        return prefix + result.misspellings.flatMap {
            format(misspelling: $0, verbose: verbose)
        }
    }

    private static func format(misspelling: Misspelling, verbose: Bool) -> [String] {
        let prefix: [String] =
            verbose
                ? [misspelling.description]
                : []


        let cols = TerminalSize()?.columns
        let context = misspelling.context(maxLineLength: cols)
        return prefix + [
            "\(misspelling.file):\(misspelling.symbolLine):\(misspelling.symbolColumn): warning: Documentation of \(misspelling.symbol) contains misspelling \"\(misspelling.misspelling)\"",
            context.sourceLine,
            context.highlightLine
        ]
    }
}
