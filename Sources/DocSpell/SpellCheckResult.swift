import Foundation
import SourceKittenFramework

struct SpellCheckResult {

    var docs: SwiftDocs

    var file: String! {
        return docs.file.path
    }

    var misspellings: [Misspelling]
}
