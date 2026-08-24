import Foundation

/// Routes the host is willing to open on request.
///
/// This enum is the allowlist. A route the backend invents but the host does
/// not know is dropped, so a stream can never navigate the app somewhere the
/// host did not sanction.
enum SandboxDeeplinkRoute: String, CaseIterable {
    case transferForm = "transfer.form"
    case statementDetail = "statement.detail"

    var title: String {
        switch self {
        case .transferForm: return "Transfer Form"
        case .statementDetail: return "Statement Detail"
        }
    }
}

/// Swift key paths cannot address tuple elements, so parameters are listed as
/// an identifiable value rather than as dictionary pairs.
struct SandboxDeeplinkParameter: Equatable, Identifiable {
    let name: String
    let value: String

    var id: String { name }
}

struct SandboxDeeplinkDestination: Equatable {
    let route: SandboxDeeplinkRoute
    let parameters: [String: String]

    var title: String { route.title }

    var sortedParameters: [SandboxDeeplinkParameter] {
        parameters
            .sorted { $0.key < $1.key }
            .map { SandboxDeeplinkParameter(name: $0.key, value: $0.value) }
    }
}

/// Builds and parses the sandbox deeplink URL.
///
/// The same URL shape a push notification or an external app would send, so
/// the hand-off reuses the existing entry point instead of a second one.
enum SandboxDeeplink {
    static let scheme = "tanyaaisandbox"
    static let host = "open"
    private static let routeKey = "route"

    static func url(
        for destination: SandboxDeeplinkDestination
    ) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.queryItems = [
            URLQueryItem(name: routeKey, value: destination.route.rawValue)
        ] + destination.sortedParameters.map {
            URLQueryItem(name: $0.name, value: $0.value)
        }
        return components.url
    }

    static func destination(from url: URL) -> SandboxDeeplinkDestination? {
        guard url.scheme == scheme,
              url.host == host,
              let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
              ),
              let queryItems = components.queryItems else {
            return nil
        }

        var parameters: [String: String] = [:]
        var routeValue: String?
        queryItems.forEach { item in
            guard let value = item.value else {
                return
            }
            if item.name == routeKey {
                routeValue = value
            } else {
                parameters[item.name] = value
            }
        }

        guard let routeValue,
              let route = SandboxDeeplinkRoute(rawValue: routeValue) else {
            return nil
        }
        return SandboxDeeplinkDestination(
            route: route,
            parameters: parameters
        )
    }
}
