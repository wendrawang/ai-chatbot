import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme.sandbox
}

public extension EnvironmentValues {
    /// Public because the screens that read it now live in another module
    /// from the components that draw with it.
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {
    func theme(_ theme: Theme) -> some View {
        environment(\.theme, theme)
    }
}
