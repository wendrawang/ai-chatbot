#if DEBUG
import SwiftUI
import TanyaAI

/// Salin bersama DemoTanyaAIComposition.swift ke target demo/Debug host.
struct DemoTanyaAIScreen: View {
    @StateObject private var host: TanyaAIHost

    init(theme: TanyaAITheme = .sandbox, onDeeplink: @escaping (URL) -> Void) {
        _host = StateObject(wrappedValue: DemoTanyaAIComposition().makeShowcaseHost(
            theme: theme,
            onDeeplink: onDeeplink
        ))
    }

    var body: some View {
        Button("Lihat semua bubble") {
            host.present()
        }
        .tanyaAIHost(host)
    }
}
#endif
