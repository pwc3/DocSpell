import Foundation
import SourceKittenFramework

public extension SpellChecker {

    enum Input {

        case swiftPackage(name: String?, path: String, arguments: [String])

        case xcodeBuild(name: String?, path: String, arguments: [String])

        case singleFiles(filenames: [String])

        internal func loadDocs() -> Result<[SwiftDocs], Error> {
            switch self {

            case .swiftPackage(let name, let path, let arguments):
                return load(from: Module(spmArguments: arguments, spmName: name, inPath: path))

            case .xcodeBuild(let name, let path, let arguments):
                return load(from: Module(xcodeBuildArguments: arguments, name: name, inPath: path))

            case .singleFiles(let filenames):
                return load(from: filenames)
            }
        }

        private func load(from module: Module?) -> Result<[SwiftDocs], Error> {
            guard let docs = module?.docs else {
                return .failure(DocSpellError.docFailed)
            }
            return .success(docs)
        }

        private func load(from filenames: [String]) -> Result<[SwiftDocs], Error> {
            return Result(catching: { try _load(from: filenames) })
        }

        // Make this a throwing function to simplify raising an error from the map closure.
        // Any failure causes the whole thing to fail.
        private func _load(from filenames: [String]) throws -> [SwiftDocs] {
            return try filenames.map { filename in
                guard let file = File(path: filename) else {
                    throw DocSpellError.readFailed(path: filename)
                }

                guard let docs = SwiftDocs(file: file, arguments: []) else {
                    throw DocSpellError.docFailed
                }

                return docs
            }
        }
    }
}
