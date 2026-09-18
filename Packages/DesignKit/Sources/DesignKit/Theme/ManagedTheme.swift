import SwiftUI

@MainActor
private struct ManagedTheme: ViewModifier {
    @ObservedObject var manager: ThemeManager
    let isDefaultForced: Bool

    func body(content: Content) -> some View {
        content.environment(\.theme, manager.resolve(isDefaultForced: isDefaultForced))
    }
}

public extension View {
    /// Apply at the root, or on a page with `isDefaultForced: true`.
    @MainActor
    func theme(_ manager: ThemeManager, isDefaultForced: Bool = false) -> some View {
        modifier(ManagedTheme(manager: manager, isDefaultForced: isDefaultForced))
    }
}
