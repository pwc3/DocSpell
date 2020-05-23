import Foundation

public enum DocSpellError: Error, CustomStringConvertible {

    case docFailed

    case readFailed(path: String)

    public var description: String {
        switch self {
        case .docFailed:
            return "Unable to generate documentation"

        case .readFailed(let path):
            return "Unable to read file at \"\(path)\""
        }
    }
}
