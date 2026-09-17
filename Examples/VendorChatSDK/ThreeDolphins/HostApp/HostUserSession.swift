import Combine
import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Owned by the app. Create chat after login; route only after chat dismissal.
final class HostUserSession: ObservableObject {
    enum Destination: String {
        case accounts
        case transfer
    }

    @Published private(set) var chatHost: TanyaAIHost?
    @Published var destination: Destination?

    func loginSucceeded(
        customer: HostCustomer,
        mapMessage: @escaping ThreeDolphinsChatSessionAdapter.MessageMapper
    ) {
        // End the previous signed-in session before switching users.
        guard chatHost == nil else { return }
        let profile = DolphinProfile(
            name: customer.name,
            email: customer.email,
            phoneNumber: customer.phoneNumber,
            customerId: customer.identifier,
            uid: customer.identifier
        )
        let composition = ThreeDolphinsTanyaAIComposition(
            profile: profile,
            deeplinkScheme: "ocbcid",
            deeplinkHost: "mobile",
            mapMessage: mapMessage
        )
        chatHost = composition.makeHost(
            theme: .sandbox,
            silentGreeting: "Halo",
            onDeeplink: { [weak self] destination in
                self?.open(destination)
            }
        )
    }

    /// Both bubble actions and external URLs enter through this router.
    func open(_ address: URL) {
        guard let chatHost,
              let components = URLComponents(url: address, resolvingAgainstBaseURL: false),
              components.scheme == "ocbcid", components.host == "mobile",
              components.user == nil, components.password == nil,
              components.port == nil, components.query == nil,
              components.fragment == nil else { return }
        let target: Destination
        switch components.path {
        case "/accounts": target = .accounts
        case "/transfer": target = .transfer
        default: return
        }
        chatHost.dismiss { [weak self] in
            self?.destination = target
        }
    }

    func logout() {
        guard let chatHost else { return }
        chatHost.dismiss { [weak self] in
            self?.destination = nil
            self?.chatHost = nil
        }
    }
}
