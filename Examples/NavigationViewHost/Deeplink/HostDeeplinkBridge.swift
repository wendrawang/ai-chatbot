import Combine
import Foundation
import TanyaAI
import UIKit

/// Routes the host is willing to open on request. This enum is the allowlist:
/// a route the backend invents but the host does not know is dropped.
enum HostRoute: String {
    case transferForm = "transfer.form"
    case statementDetail = "statement.detail"
}

struct HostDestination: Equatable {
    let route: HostRoute
    let parameters: [String: String]
}

/// Bridges a Tanya AI action to the host's existing deeplink entry point.
///
/// Sequencing is the whole job. The feature is presented full screen over the
/// legacy hierarchy, so the destination cannot be pushed while it is still
/// visible, and the deeplink has to land on the dashboard first.
final class HostDeeplinkBridge: ObservableObject {
    @Published var activeDestination: HostDestination?
    @Published private(set) var hasPendingDestination = false

    private var pendingDestination: HostDestination?
    private weak var presenter: HostTanyaAIPresenter?

    init(presenter: HostTanyaAIPresenter) {
        self.presenter = presenter
    }

    /// Handler passed to `TanyaAIModule.makeView(onAction:)`.
    @discardableResult
    func handle(_ action: TanyaAIAction) -> Bool {
        guard let route = HostRoute(rawValue: action.route),
              let url = makeURL(route: route, parameters: action.parameters)
        else {
            return false
        }
        // Round-trip so the hand-off reuses the existing deeplink path.
        // Calling `receive(url)` directly works too and is easier to test.
        UIApplication.shared.open(url)
        return true
    }

    /// The single deeplink entry point: cold start, push notification,
    /// external app, and the Tanya AI hand-off all land here.
    @discardableResult
    func receive(_ url: URL) -> Bool {
        guard let destination = parse(url) else {
            return false
        }
        pendingDestination = destination
        hasPendingDestination = true
        presenter?.dismissTanyaAI()
        return true
    }

    /// Call from `fullScreenCover(onDismiss:)`, after popping to the
    /// dashboard.
    func deliverPendingDestination() {
        guard let destination = pendingDestination else {
            return
        }
        pendingDestination = nil
        hasPendingDestination = false
        activeDestination = destination
    }

    func clearDestination() {
        activeDestination = nil
    }

    private func makeURL(
        route: HostRoute,
        parameters: [String: String]
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "hostapp"
        components.host = "open"
        components.queryItems =
            [URLQueryItem(name: "route", value: route.rawValue)]
            + parameters.sorted { $0.key < $1.key }.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        return components.url
    }

    private func parse(_ url: URL) -> HostDestination? {
        guard url.scheme == "hostapp",
              url.host == "open",
              let items = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
              )?.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        var routeValue: String?
        items.forEach { item in
            guard let value = item.value else { return }
            if item.name == "route" {
                routeValue = value
            } else {
                parameters[item.name] = value
            }
        }

        guard let routeValue, let route = HostRoute(rawValue: routeValue) else {
            return nil
        }
        return HostDestination(route: route, parameters: parameters)
    }
}
