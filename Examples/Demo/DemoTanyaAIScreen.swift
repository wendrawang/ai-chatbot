#if DEBUG
    import SwiftUI
    import TanyaAI

    /// Salin bersama DemoTanyaAIComposition.swift ke target demo/Debug host.
    @MainActor
    struct DemoTanyaAIScreen: View {
        @StateObject
        private var host: TanyaAIHost

        init(theme: TanyaAITheme = .sandbox, onDeeplink: @escaping (URL) -> Void) {
            _host = StateObject(
                wrappedValue: DemoTanyaAIComposition().makeHost(
                    theme: theme,
                    onDeeplink: onDeeplink
                ))
        }

        var body: some View {
            Button("Buka percakapan") {
                host.present()
            }
            .tanyaAIHost(host)
        }
    }
#endif
