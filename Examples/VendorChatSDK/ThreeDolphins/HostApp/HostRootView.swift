import SwiftUI
import TanyaAI

/// Demonstration login and destinations; replace them with the host's actual screens.
struct HostRootView: View {
    @ObservedObject var session: HostUserSession
    let isChatConfigured: Bool

    var body: some View {
        Group {
            if let chatHost = session.chatHost {
                home(chatHost: chatHost)
            } else {
                Button("Login demo") {
                    session.loginSucceeded(
                        customer: HostCustomer(
                            identifier: "demo-user",
                            name: "Demo User",
                            email: "demo@example.com",
                            phoneNumber: "080000000000"
                        ),
                        mapMessage: ThreeDolphinsMessageMapper.map
                    )
                }
                .disabled(!isChatConfigured)
                .overlay(alignment: .bottom) {
                    if !isChatConfigured {
                        Text("Isi konfigurasi Livechat di Info.plist host.")
                            .offset(y: 40)
                    }
                }
            }
        }
    }

    private func home(chatHost: TanyaAIHost) -> some View {
        NavigationView {
            VStack(spacing: 16) {
                Button("Buka TanyaAI") { chatHost.present() }
                Button("Logout") { session.logout() }
                NavigationLink(
                    "Rekening",
                    tag: HostUserSession.Destination.accounts,
                    selection: $session.destination
                ) {
                    Text("Contoh tujuan rekening host").navigationTitle("Rekening")
                }
                NavigationLink(
                    "Transfer",
                    tag: HostUserSession.Destination.transfer,
                    selection: $session.destination
                ) {
                    Text("Contoh tujuan transfer host").navigationTitle("Transfer")
                }
            }
            .navigationTitle("Home")
        }
        .navigationViewStyle(.stack)
        .tanyaAIHost(chatHost)
    }
}
