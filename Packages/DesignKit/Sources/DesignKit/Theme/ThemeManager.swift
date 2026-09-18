import Combine

public enum ThemeVariant: String, CaseIterable {
    case `default`
    case premier
    case `private`
}

/// Own one manager at the app root. Palettes come from the host's generated tokens.
@MainActor
public final class ThemeManager: ObservableObject {
    @Published public var selected: ThemeVariant
    @Published public var isDefaultForced: Bool

    private let defaultTheme: Theme
    private let premierTheme: Theme
    private let privateTheme: Theme

    public init(
        defaultTheme: Theme,
        premierTheme: Theme,
        privateTheme: Theme,
        selected: ThemeVariant = .default,
        isDefaultForced: Bool = false
    ) {
        self.defaultTheme = defaultTheme
        self.premierTheme = premierTheme
        self.privateTheme = privateTheme
        self.selected = selected
        self.isDefaultForced = isDefaultForced
    }

    public var theme: Theme { resolve() }

    /// A page override never changes the user's selected theme.
    public func resolve(isDefaultForced: Bool = false) -> Theme {
        guard !self.isDefaultForced, !isDefaultForced else {
            return defaultTheme
        }
        switch selected {
        case .default: return defaultTheme
        case .premier: return premierTheme
        case .private: return privateTheme
        }
    }
}
