import Foundation

struct FileHandleOutputStream: TextOutputStream {

    private let handle: FileHandle

    init(handle: FileHandle) {
        self.handle = handle
    }

    func write(_ string: String) {
        guard let data = string.data(using: .utf8) else {
            return
        }
        handle.write(data)
    }
}

var stdout = FileHandleOutputStream(handle: .standardOutput)
var stderr = FileHandleOutputStream(handle: .standardError)
