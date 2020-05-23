import Foundation

struct Fixture {

    static var directory: URL {
        URL(fileURLWithPath: #file).deletingLastPathComponent()
    }

    static func url(for name: String) -> URL {
        return directory.appendingPathComponent(name)
    }

    static func path(for name: String) -> String {
        return url(for: name).path
    }

    static func contents(of name: String) throws -> String {
        return try String(contentsOf: url(for: name))
    }
}
