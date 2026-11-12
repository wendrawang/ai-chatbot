//
//  check_methods.swift
//  ai-chatbot
//
//  Created by Wendra on 15/10/26.
//

import Foundation
import SwiftParser
import SwiftSyntax

final class Auditor: SyntaxVisitor {
    var isValid = true
    let path: String
    let locations: SourceLocationConverter

    /// Satu file satu tipe hanya dijaga di package. Token dan identifier UI test memang dikelompokkan bersarang,
    /// dan spesifikasi format hex tetap private di file pemakainya (lihat AGENTS.md).
    let isTypeLayoutChecked: Bool
    var topLevelTypes: [String] = []

    init(path: String, tree: SourceFileSyntax) {
        self.path = path
        self.locations = SourceLocationConverter(fileName: path, tree: tree)
        let exemptions = ["/Tokens/", "/ComponentIdentifier.swift", "/Color+Hex.swift"]
        self.isTypeLayoutChecked = path.contains("/Packages/") && !exemptions.contains { path.contains($0) }
        super.init(viewMode: .sourceAccurate)
    }

    func checkType(_ syntax: some SyntaxProtocol, name: String) {
        guard isTypeLayoutChecked else { return }
        let line = locations.location(for: syntax.positionAfterSkippingLeadingTrivia).line
        var ancestor = syntax.parent
        while let current = ancestor {
            if current.is(MemberBlockSyntax.self) {
                isValid = false
                print("\(path):\(line): \(name) is nested; move it to its own file")
                return
            }
            ancestor = current.parent
        }
        topLevelTypes.append(name)
        if topLevelTypes.count > 1 {
            isValid = false
            print("\(path):\(line): \(name) shares a file with \(topLevelTypes[0]); one type per file")
        }
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        checkType(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        checkType(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        checkType(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: ActorDeclSyntax) -> SyntaxVisitorContinueKind {
        checkType(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        checkType(node, name: node.name.text)
        return .visitChildren
    }

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
