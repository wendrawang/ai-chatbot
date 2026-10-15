import UIKit

/// Resource filenames and PostScript names are separate font metadata.
public enum FontFace: String, CaseIterable {
    case regular = "OpenSans-Regular.ttf"
    case medium = "OpenSans-Medium.ttf"

    private static let directoryName = "Fonts"

    public var postScriptName: String {
        switch self {
        case .regular: return "OpenSansRoman-Regular"
        case .medium: return "OpenSansRoman-Medium"
        }
    }

    public func font(size: CGFloat) -> UIFont {
        UIFont(name: postScriptName, size: size) ?? UIFont.systemFont(ofSize: size)
    }

    /// Call during bootstrap before presenting components; registration is process-scoped and idempotent.
    public static func registerFonts() throws {
        try FontLoader.register(
            fileNames: allCases.map(\.rawValue), bundle: .module, subdirectory: directoryName
        )
    }
}
