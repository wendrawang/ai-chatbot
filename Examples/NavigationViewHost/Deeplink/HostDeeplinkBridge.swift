import Combine
import Foundation
import TanyaAI
import UIKit

/// Destinations this app is willing to open on request.
///
/// This enum is the allowlist. Keep it in the host: only the app knows which
/// destinations exist and which of them a chat response may reach.
enum HostDeeplinkType: String {
    case transfer
    case statement
}

/// A deeplink that passed validation, ready to be pushed.
struct HostDestination: Equatable {
    let type: HostDeeplinkType
    let parameters: [String: String]
}

/// Bridges a Tanya AI action to the host's existing deeplink entry point.
///
/// Two jobs: decide whether a deeplink may be opened at all, and hold the
/// destination until the screen is clear. The feature is presented full screen
/// over the legacy hierarchy, so a destination cannot be pushed while it is
/// still visible, and the deeplink has to land on the dashboard first.
final class HostDeeplinkBridge: ObservableObject {
    /// The destination currently pushed. `nil` means the stack is back on the
    /// dashboard.
    @Published var activeDestination: HostDestination?

    /// Set while a validated destination waits to be pushed.
    @Published private(set) var hasPendingDestination = false

    /// True when the destination must wait for the feature to finish
    /// dismissing. False when the deeplink arrived with nothing presented, so
    /// the host can deliver it right away.
    @Published private(set) var awaitsDismissal = false

    private var pendingDestination: HostDestination?
    private weak var presenter: HostTanyaAIPresenter?

    init(presenter: HostTanyaAIPresenter) {
        self.presenter = presenter
    }

    /// Handler passed to `TanyaAIModule.makeView(onAction:)`.
    ///
    /// The response sends a full deeplink string such as
    /// `ocbcid://mobile?type=transfer`. Validate it, then open it so the
    /// hand-off runs the same code path a push notification would. Returns
    /// `false` — and does nothing — when the link is not one this app accepts.
    @discardableResult
    func handle(_ action: TanyaAIAction) -> Bool {
        guard let url = URL(string: action.deeplink),
              validate(url) != nil else {
            return false
        }
        // Round-trip so the hand-off reuses the existing deeplink path.
        // Calling `receive(url)` directly works too and is easier to test.
        UIApplication.shared.open(url)
        return true
    }

    /// The single deeplink entry point: cold start, push notification,
    /// external app, and the Tanya AI hand-off all land here.
    ///
    /// Validates again, because this URL can come from anywhere, then holds
    /// the destination and asks the feature to close if it is on screen.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let destination = validate(url) else {
            return false
        }
        let isPresented = presenter?.isPresented ?? false
        pendingDestination = destination
        awaitsDismissal = isPresented
        hasPendingDestination = true

        if isPresented {
            presenter?.dismissTanyaAI()
        }
        return true
    }

    /// Pushes the pending destination. Call it once the screen is clear:
    /// after the feature dismissed and the stack returned to the dashboard.
    func deliverPendingDestination() {
        guard let destination = pendingDestination else {
            return
        }
        pendingDestination = nil
        hasPendingDestination = false
        awaitsDismissal = false
        activeDestination = destination
    }

    /// Called when the user navigates back, so the destination is not restored
    /// on the next render.
    func clearDestination() {
        activeDestination = nil
    }

    /// The security boundary. Four checks, in order:
    ///
    /// 1. the scheme is this app's — which is what rejects `https://…`,
    ///    `tel:`, and links into other apps;
    /// 2. the host is the expected entry point;
    /// 3. `type` is in the allowlist;
    /// 4. everything else is passed through as parameters.
    ///
    /// Whatever your existing deeplink handler already does, reuse it here
    /// instead of writing a second parser.
    private func validate(_ url: URL) -> HostDestination? {
        guard url.scheme == "ocbcid",
              url.host == "mobile",
              let items = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
              )?.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        var typeValue: String?
        items.forEach { item in
            guard let value = item.value else { return }
            if item.name == "type" {
                typeValue = value
            } else {
                parameters[item.name] = value
            }
        }

        guard let typeValue,
              let type = HostDeeplinkType(rawValue: typeValue) else {
            return nil
        }
        return HostDestination(type: type, parameters: parameters)
    }
}
