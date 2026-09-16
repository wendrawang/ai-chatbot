import Foundation

public enum DesignKitFont: String, CaseIterable {
    case firaBold = "FiraSans-Bold"
    case firaMedium = "FiraSans-Medium"
    case firaRegular = "FiraSans-Regular"
    case firaSemibold = "FiraSans-SemiBold"
    case openBold = "OpenSans-Bold"
    case openMedium = "OpenSans-Medium"
    case openRegular = "OpenSans-Regular"

    public var postScriptName: String {
        switch self {
        case .openBold: return "OpenSansRoman-Bold"
        case .openMedium: return "OpenSansRoman-Medium"
        case .openRegular: return "OpenSansRoman-Regular"
        default: return rawValue
        }
    }

    /// Register once before creating a ThemeManager. Repeated calls are harmless.
    public static func registerFonts() throws {
        try FontLoader.register(
            fileNames: allCases.map { $0.rawValue + ".ttf" },
            bundle: .module,
            subdirectory: "Fonts"
        )
    }
}
