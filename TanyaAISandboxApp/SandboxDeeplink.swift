import Foundation

/// Destinations this app is willing to open on request.
///
/// This enum is the allowlist. A `type` the backend invents but the app does
/// not know is dropped, so a response can never steer the app somewhere the
/// host never sanctioned.
enum SandboxDeeplinkType: String, CaseIterable {
    case transfer
    case statement

    var title: String {
        switch self {
        case .transfer: return "Transfer Form"
        case .statement: return "Statement Detail"
        }
    }
}

/// Swift key paths cannot address tuple elements, so query values are listed
/// as an identifiable value rather than as dictionary pairs.
struct SandboxDeeplinkParameter: Equatable, Identifiable {
    let name: String
    let value: String

    var id: String { name }
}

/// A deeplink that passed validation, ready to be pushed.
struct SandboxDeeplinkDestination: Equatable {
    let type: SandboxDeeplinkType
    let parameters: [String: String]
    /// The original string, kept for logging and for the demo screen.
    let deeplink: String

    var title: String { type.title }

    var sortedParameters: [SandboxDeeplinkParameter] {
        parameters
            .sorted { $0.key < $1.key }
            .map { SandboxDeeplinkParameter(name: $0.key, value: $0.value) }
    }
}

/// Validates the deeplinks this app accepts.
///
/// Shape: `tanyaaisandbox://mobile?type=transfer&amount=1250000` — the same
/// shape a push notification or another app would send.
enum SandboxDeeplink {
    static let scheme = "tanyaaisandbox"
    static let host = "mobile"
    private static let typeKey = "type"

    /// Turns the string a response sent into a destination, or `nil` when it
    /// fails any check.
    ///
    /// Four checks, in order:
    /// 1. it parses as a URL at all;
    /// 2. the scheme is this app's — which is what rejects `https://…`,
    ///    `tel:`, and links into other apps;
    /// 3. the host is the expected entry point;
    /// 4. `type` is in the allowlist above.
    ///
    /// Everything else in the query is passed through as parameters.
    static func destination(from deeplink: String) -> SandboxDeeplinkDestination? {
        guard let url = URL(string: deeplink) else {
            return nil
        }
        return destination(from: url)
    }

    /// Same validation, for a `URL` that arrived from the system.
    static func destination(from url: URL) -> SandboxDeeplinkDestination? {
        guard url.scheme == scheme,
              url.host == host,
              let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
              ) else {
            return nil
        }

        var parameters: [String: String] = [:]
        var typeValue: String?
        (components.queryItems ?? []).forEach { item in
            guard let value = item.value else {
                return
            }
            if item.name == typeKey {
                typeValue = value
            } else {
                parameters[item.name] = value
            }
        }

        guard let typeValue,
              let type = SandboxDeeplinkType(rawValue: typeValue) else {
            return nil
        }
        return SandboxDeeplinkDestination(
            type: type,
            parameters: parameters,
            deeplink: url.absoluteString
        )
    }
}
