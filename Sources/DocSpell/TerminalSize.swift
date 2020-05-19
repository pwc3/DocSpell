import Foundation

/// The window size of the current terminal.
struct TerminalSize {

    /// The number of columns in the current terminal window.
    var columns: Int

    /// The number of rows in the current terminal window.
    var rows: Int

    /// Queries the parameters of the `stdout` file handle to determine the terminal window size. Returns `nil` if `stdout` is not directed to a terminal (e.g., if we are running in the debugger in Xcode).
    init?() {
        var size = winsize()
        guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &size) == 0 else {
            return nil
        }

        self.init(columns: Int(size.ws_col), rows: Int(size.ws_row))
    }

    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
    }
}
