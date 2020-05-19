import Foundation

struct SpellCheckResultFormatter {

    static func format(results: [SpellCheckResult]) -> [String] {
        return results.compactMap(format(result:))
    }

    static func format(result: SpellCheckResult) -> String? {
        return result.misspellings.isEmpty
            ? nil
            : result.misspellings.map(format(misspelling:)).joined(separator: "\n")
    }

    static func format(misspelling: Misspelling) -> String {
        let cols = TerminalSize()?.columns
        let context = misspelling.context(maxLineLength: cols)
        return [
            "\(misspelling.file):\(misspelling.symbolLine):\(misspelling.symbolColumn): warning: Documentation of \(misspelling.symbol) contains misspelling \"\(misspelling.misspelling)\"",
            context.sourceLine,
            context.highlightLine
        ].joined(separator: "\n")
    }
}
