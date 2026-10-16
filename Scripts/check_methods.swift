// Created by Wendra on 16/10/26.

import Foundation
import SwiftParser
import SwiftSyntax

final class Auditor: SyntaxVisitor
{
    var isValid = true
    let path: String
    let locations: SourceLocationConverter

    init(path: String, tree: SourceFileSyntax)
    {
        self.path = path
        self.locations = SourceLocationConverter(fileName: path, tree: tree)
        super.init(viewMode: .sourceAccurate)
    }

    func check(_ syntax: some SyntaxProtocol, name: String)
    {
        let start = locations.location(for: syntax.positionAfterSkippingLeadingTrivia).line
        let end = locations.location(for: syntax.endPositionBeforeTrailingTrivia).line
        if end - start + 1 > 50
        {
            isValid = false
            print("\(path):\(start): \(name) spans \(end - start + 1) physical lines")
        }
    }

    func fail(_ node: some SyntaxProtocol, _ reason: String)
    {
        isValid = false
        let line = locations.location(for: node.positionAfterSkippingLeadingTrivia).line
        print("\(path):\(line): \(reason)")
    }

    override func visit(_ token: TokenSyntax) -> SyntaxVisitorContinueKind
    {
        guard token.tokenKind == .leftBrace
        else
        {
            return .visitChildren
        }

        let location = locations.location(for: token.positionAfterSkippingLeadingTrivia)
        guard location.column > 1
        else
        {
            return .visitChildren
        }

        let prefix = locations.sourceLines[location.line - 1].prefix(location.column - 1)
        guard prefix.trimmingCharacters(in: .whitespaces).isEmpty
        else
        {
            fail(token, "Allman opening brace must be on its own line")
            return .visitChildren
        }

        return .visitChildren
    }

    override func visit(_ node: IfExprSyntax) -> SyntaxVisitorContinueKind
    {
        var ancestor = node.parent
        while let current = ancestor
        {
            guard !current.is(IfExprSyntax.self)
            else
            {
                fail(node, "Nested if/else chain is not allowed")
                return .visitChildren
            }

            ancestor = current.parent
        }

        return .visitChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind
    {
        guard !node.modifiers.contains(where:
            {
                $0.name.text == "override"
            })
        else
        {
            return .visitChildren
        }

        for binding in node.bindings
        {
            let isBoolean = binding.typeAnnotation?.type.trimmedDescription == "Bool"
                || ["true", "false"].contains(binding.initializer?.value.trimmedDescription ?? "")
            guard isBoolean, let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else
            {
                continue
            }

            guard !name.hasPrefix("is")
            else
            {
                continue
            }

            fail(binding, "Boolean properties must start with is")
        }

        return .visitChildren
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind
    {
        check(node, name: node.name.text)
        return .visitChildren
    }

    override func visit(_ node: InitializerDeclSyntax) -> SyntaxVisitorContinueKind
    {
        check(node, name: "init")
        return .visitChildren
    }

    override func visit(_ node: DeinitializerDeclSyntax) -> SyntaxVisitorContinueKind
    {
        check(node, name: "deinit")
        return .visitChildren
    }

    override func visit(_ node: PatternBindingSyntax) -> SyntaxVisitorContinueKind
    {
        if let accessor = node.accessorBlock
        {
            check(accessor, name: node.pattern.trimmedDescription)
        }

        return .visitChildren
    }
}

var isValid = true
for path in CommandLine.arguments.dropFirst()
{
    let source = try String(contentsOfFile: path, encoding: .utf8)
    let tree = Parser.parse(source: source)
    let auditor = Auditor(path: path, tree: tree)
    auditor.walk(tree)
    isValid = isValid && auditor.isValid
}

exit(isValid ? 0 : 1)
