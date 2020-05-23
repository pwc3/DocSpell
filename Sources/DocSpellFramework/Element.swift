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

    private func get<T>(_ key: SwiftDocKey) -> T? {
        return dictionary[key.rawValue] as? T
    }

    // MARK: - SourceKit Keys

    /// Annotated declaration (String).
    var annotatedDeclaration: String? { return get(.annotatedDeclaration) }

    /// Body length (Int64).
    var bodyLength: Int64? { return get(.bodyLength) }

    /// Body offset (Int64).
    var bodyOffset: Int64? { return get(.bodyOffset) }

    /// Diagnostic stage (String).
    var diagnosticStage: String? { return get(.diagnosticStage) }

    /// Elements ([Element]).
    var elements: [Element]? {
        let d: [[String: SourceKitRepresentable]]? = get(.elements)
        return d?.map { Element(dictionary: $0)}
    }

    /// File path (String).
    var filePath: String? { return get(.filePath) }

    /// Full XML docs (String).
    var fullXMLDocs: String? { return get(.fullXMLDocs) }

    /// Kind (String).
    var kind: String? { return get(.kind) }

    /// Length (Int64).
    var length: Int64? { return get(.length) }

    /// Name (String).
    var name: String? { return get(.name) }

    /// Name length (Int64).
    var nameLength: Int64? { return get(.nameLength) }

    /// Name offset (Int64).
    var nameOffset: Int64? { return get(.nameOffset) }

    /// Offset (Int64).
    var offset: Int64? { return get(.offset) }

    /// Substructure ([Element]).
    var substructure: [Element]? {
        let d: [[String: SourceKitRepresentable]]? = get(.substructure)
        return d?.map { Element(dictionary: $0)}
    }

    /// Syntax map (NSData).
    var syntaxMap: NSData? { return get(.syntaxMap) }

    /// Type name (String).
    var typeName: String? { return get(.typeName) }

    /// Inheritedtype ([SourceKitRepresentable])
    var inheritedtypes: [SourceKitRepresentable] { return get(.inheritedtypes) ?? [] }

    // MARK: - Custom Keys

    /// Column where the token's declaration begins (Int64).
    var docColumn: Int64? { return get(.docColumn) ?? 0 }

    /// Documentation comment (String).
    var documentationComment: String? { return get(.documentationComment) }

    /// Declaration of documented token (String).
    var docDeclaration: String? { return get(.docDeclaration) }

    /// Discussion documentation of documented token ([SourceKitRepresentable]).
    var docDiscussion: [SourceKitRepresentable]? { return get(.docDiscussion) }

    /// File where the documented token is located (String).
    var docFile: String? { return get(.docFile) }

    /// Line where the token's declaration begins (Int64).
    var docLine: Int64? { return get(.docLine) }

    /// Name of documented token (String).
    var docName: String? { return get(.docName) }

    /// Parameters of documented token ([SourceKitRepresentable]).
    var docParameters: [SourceKitRepresentable]? { return get(.docParameters) }

    /// Result discussion documentation of documented token ([SourceKitRepresentable]).
    var docResultDiscussion: [SourceKitRepresentable]? { return get(.docResultDiscussion) }

    /// Type of documented token (String).
    var docType: String? { return get(.docType) }

    /// USR of documented token (String).
    var usr: String? { return get(.usr) }

    /// Parsed declaration (String).
    var parsedDeclaration: String? { return get(.parsedDeclaration) }

    /// Parsed scope end (Int64).
    var parsedScopeEnd: Int64? { return get(.parsedScopeEnd) }

    /// Parsed scope end (Int64).
    var parsedScopeStart: Int64? { return get(.parsedScopeStart) }

    /// Swift Declaration (String).
    var swiftDeclaration: String? { return get(.swiftDeclaration) }

    /// Swift Name (String).
    var swiftName: String? { return get(.swiftName) }

    /// Always deprecated (Bool).
    var alwaysDeprecated: Bool? { return get(.alwaysDeprecated) }

    /// Always unavailable (Bool).
    var alwaysUnavailable: Bool? { return get(.alwaysUnavailable) }

    /// Deprecation message (String).
    var deprecationMessage: String? { return get(.deprecationMessage) }

    /// Unavailable message (String).
    var unavailableMessage: String? { return get(.unavailableMessage) }

    /// Annotations ([String]).
    var annotations: [String]? { return get(.annotations) }

    // MARK: - DocSpell Extensions

    /// The best offset for this declaration. Prefers `nameOffset`, but some declarations (e.g., enum cases) have an invalid 0 here.
    ///
    /// See: SwiftDocKey.getBestOffset(_:)
    var bestOffset: Int64? {
        if let nameOffset = nameOffset, nameOffset > 0 {
            return nameOffset
        }
        return offset
    }

    /// Doc comment begins at this byte offset in the file.
    var docLength: Int64? {
        return dictionary["key.doclength"] as? Int64
    }

    /// Doc comment length in bytes.
    var docOffset: Int64? {
        return dictionary["key.docoffset"] as? Int64
    }
}

extension Element {

    func findDocumentation() -> [Element] {
        let base: [Element]

        if documentationComment != nil {
            base = [self]
        }
        else {
            base = []
        }

        return base + (substructure?.flatMap({ $0.findDocumentation() }) ?? [])
    }
}
