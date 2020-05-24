//
//  Element.swift
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
import SourceKittenFramework

struct Element {

    private var dictionary: [String: SourceKitRepresentable]

    init(dictionary: [String: SourceKitRepresentable]) {
        self.dictionary = dictionary
    }

    /// Substructure ([Element]).
    var substructure: [Element]? {
        let d = dictionary["key.substructure"] as? [[String: SourceKitRepresentable]]
        return d?.map { Element(dictionary: $0)}
    }

    /// Processed doc comment (String).
    var docComment: String? {
        return dictionary["key.doc.comment"] as? String
    }

    /// Source doc comment length in bytes.
    var docLength: ByteCount? {
        return (dictionary["key.doclength"] as? Int64).map(ByteCount.init)
    }

    /// Source doc comment begins at this byte offset in the file.
    var docOffset: ByteCount? {
        return (dictionary["key.docoffset"] as? Int64).map(ByteCount.init)
    }

    var docCommentByteRange: ByteRange? {
        guard let location = docOffset, let length = docLength else {
            return nil
        }

        return ByteRange(location: location, length: length)
    }

    func findDocumentation() -> [Element] {
        let base: [Element] =
            docComment != nil
                ? [self]
                : []

        return base + (substructure?.flatMap({ $0.findDocumentation() }) ?? [])
    }
}
