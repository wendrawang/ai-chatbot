import Foundation

enum SandboxLaunchMode {
    case legacyHost
    case showcase
    case deeplink
    /// Chat driven by a vendor SDK session instead of the SSE transport.
    case vendorSession

    init(arguments: [String]) {
        if arguments.contains("--showcase") {
            self = .showcase
        } else if arguments.contains("--deeplink") {
            self = .deeplink
        } else if arguments.contains("--vendor-session") {
            self = .vendorSession
        } else {
            self = .legacyHost
        }
    }

    /// Opens the feature directly instead of the legacy host screen.
    ///
    /// The deeplink demo stays on the legacy host: the hand-off has to land
    /// back on the dashboard, so the dashboard must exist.
    var isStandaloneFeature: Bool {
        switch self {
        case .legacyHost, .deeplink:
            return false
        case .showcase, .vendorSession:
            return true
        }
    }

    /// Shortens the mock chunk delay so a UI run does not wait on simulated
    /// streaming.
    var usesFastStreaming: Bool {
        switch self {
        case .legacyHost:
            return false
        case .showcase, .deeplink, .vendorSession:
            return true
        }
    }

    var initialPrompt: String? {
        switch self {
        case .legacyHost:
            return nil
        case .showcase:
            return "showcase all bubbles"
        case .deeplink:
            return "deeplink hand-off"
        case .vendorSession:
            return "vendor session demo"
        }
    }

    /// Swaps the mock SSE transport for a mock vendor chat session.
    /// Everything above the repository is identical, which is the point.
    var usesVendorSession: Bool {
        self == .vendorSession
    }
}
