//
//  check_methods.swift
//  ai-chatbot
//
//  Created by Wendra on 15/10/26.
//

import Foundation
import SwiftParser
import SwiftSyntax

/// Batas fisik method dan aturan tipe: satu tipe per file, tanpa tipe nested (kecuali token),
/// dan class hanya bila framework mewajibkannya.
final class Auditor: SyntaxVisitor {
    /// Superclass/protocol yang memang mensyaratkan class.
    static let classBases: Set<String> = [
        "ObservableObject", "NSObject", "UIResponder", "UIViewController", "UITableViewCell", "UITextView",
        "XCTestCase", "SyntaxVisitor", "ScreenContentViewModel"
    ]
    var isValid = true
    let path: String
    let locations: SourceLocationConverter
    let isTokenFile: Bool
    var typeDepth = 0
    var topLevelTypes: [String] = []

    init(path: String, tree: SourceFileSyntax) {
        self.path = path
        self.locations = SourceLocationConverter(fileName: path, tree: tree)
        isTokenFile = path.contains("/Tokens/") || path.hasSuffix("ComponentIdentifier.swift")
        super.init(viewMode: .sourceAccurate)
    }

    func report(_ syntax: some SyntaxProtocol, _ message: String) {
        isValid = false
        let line = locations.location(for: syntax.positionAfterSkippingLeadingTrivia).line
        print("\(path):\(line): \(message)")
    }

    /// Catat tipe baru; nested (di dalam tipe atau extension) hanya boleh di file token.
    func enterType(_ syntax: some SyntaxProtocol, name: String) {
        if typeDepth > 0 {
            if !isTokenFile { report(syntax, "\(name) is nested; give it its own file") }
        } else {
            topLevelTypes.append(name)
            if topLevelTypes.count > 1 { report(syntax, "one type per file; found \(topLevelTypes)") }
        }
        typeDepth += 1
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        enterType(node, name: node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) { typeDepth -= 1 }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        enterType(node, name: node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) { typeDepth -= 1 }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        enterType(node, name: node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: ActorDeclSyntax) { typeDepth -= 1 }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        enterType(node, name: node.name.text)
        return .visitChildren
    }

    override func visitPost(_ node: ProtocolDeclSyntax) { typeDepth -= 1 }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        enterType(node, name: node.name.text)
        let bases = Set(node.inheritanceClause?.inheritedTypes.map { $0.type.trimmedDescription } ?? [])
        if bases.isDisjoint(with: Self.classBases) {
            report(node, "class \(node.name.text) is not required by a framework base; use struct, enum or actor")
        }
        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) { typeDepth -= 1 }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        typeDepth += 1
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) { typeDepth -= 1 }

    func check(_ syntax: some SyntaxProtocol, name: String) {
        let start = locations.location(for: syntax.positionAfterSkippingLeadingTrivia).line
        let end = locations.location(for: syntax.endPositionBeforeTrailingTrivia).line
        if end - start + 1 > 50 {
            isValid = false
            print("\(path):\(start): \(name) spans \(end - start + 1) physical lines")
        }
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node, name: "init")
        return .visitChildren
    }

    override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind {
        check(node, name: "deinit")
        return .visitChildren
    }

    override func visit(_ node: PatternBindingSyntax) -> SyntaxVisitorContinueKind {
        if let accessor = node.accessorBlock { check(accessor, name: node.pattern.trimmedDescription) }
        return .visitChildren
    }
}

var isValid = true
for path in CommandLine.arguments.dropFirst() {
    let source = try String(contentsOfFile: path, encoding: .utf8)
    let tree = Parser.parse(source: source)
    let auditor = Auditor(path: path, tree: tree)
    auditor.walk(tree)
    isValid = isValid && auditor.isValid
}
exit(isValid ? 0 : 1)
