import Foundation
import SwiftParser
import SwiftSyntax

final class Auditor: SyntaxVisitor {
    var isValid = true
    let path: String
    let locations: SourceLocationConverter

    init(path: String, tree: SourceFileSyntax) {
        self.path = path
        self.locations = SourceLocationConverter(fileName: path, tree: tree)
        super.init(viewMode: .sourceAccurate)
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
