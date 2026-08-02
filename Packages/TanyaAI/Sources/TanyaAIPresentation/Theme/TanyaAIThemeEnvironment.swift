import SwiftUI
import TanyaAIDesignSystem

private struct TanyaAIThemeKey: EnvironmentKey {
    static let defaultValue = TanyaAITheme.sandbox
}

extension EnvironmentValues {
    var tanyaAITheme: TanyaAITheme {
        get { self[TanyaAIThemeKey.self] }
        set { self[TanyaAIThemeKey.self] = newValue }
    }
}

public extension View {
    func tanyaAITheme(_ theme: TanyaAITheme) -> some View {
        environment(\.tanyaAITheme, theme)
    }
}
