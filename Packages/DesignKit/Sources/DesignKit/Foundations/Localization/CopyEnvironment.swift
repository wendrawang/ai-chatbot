import SwiftUI

private struct CopyCatalogKey: EnvironmentKey {
    static let defaultValue = CopyCatalog()
}

public extension EnvironmentValues {
    var copyCatalog: CopyCatalog {
        get { self[CopyCatalogKey.self] }
        set { self[CopyCatalogKey.self] = newValue }
    }
}

public extension View {
    /// Reapply with a new value when the host changes language. Also updates
    /// locale-sensitive SwiftUI formatting in the same subtree.
    func copyCatalog(_ catalog: CopyCatalog) -> some View {
        environment(\.copyCatalog, catalog)
            .environment(\.locale, Locale(identifier: catalog.localeIdentifier))
    }
}
