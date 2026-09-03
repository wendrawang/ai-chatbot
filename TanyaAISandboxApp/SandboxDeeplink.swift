import Foundation

/// Validates that a link belongs to this app, and nothing more.
///
/// Shape: `tanyaaisandbox://mobile?type=transfer&amount=1250000` — the same
/// shape a push notification or another app would send.
///
/// Only two checks live here, because only two are the package's business to
/// force on the host: the scheme is this app's, and the host is the app's
/// deeplink entry point. Everything after that — which screen a `type` means,
/// which parameters it takes — belongs to the app's existing deeplink
/// dispatcher, which already knows.
enum SandboxDeeplink {
    static let scheme = "tanyaaisandbox"
    static let host = "mobile"

    /// Accepts the string a response sent, or `nil` when it is not a link this
    /// app opens.
    ///
    /// The scheme check is the one that matters: it rejects `https://…`,
    /// `tel:`, and links that would launch a different app.
    static func accepted(_ deeplink: String) -> URL? {
        guard let url = URL(string: deeplink) else {
            return nil
        }
        return accepted(url)
    }

    /// Same check for a `URL` that arrived from the system.
    static func accepted(_ url: URL) -> URL? {
        guard url.scheme == scheme, url.host == host else {
            return nil
        }
        return url
    }
}

/// Swift key paths cannot address tuple elements, so query values are listed
/// as an identifiable value rather than as dictionary pairs.
struct SandboxDeeplinkParameter: Equatable, Identifiable {
    let name: String
    let value: String

    var id: String { name }
}

/// Stand-in for the deeplink dispatcher the host application already owns.
///
/// A real app has this already: the code that reads the URL and decides which
/// screen to open. The sandbox has no such code, so it keeps a tiny version
/// here. In your project this whole type is replaced by the call into your
/// existing handler.
enum SandboxDeeplinkDispatcher {
    static func destination(for url: URL) -> SandboxDeeplinkDestination? {
        guard let components = URLComponents(
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
            if item.name == "type" {
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

/// Screens the sandbox dispatcher knows how to open.
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

/// A deeplink that passed validation and resolved to a screen.
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
