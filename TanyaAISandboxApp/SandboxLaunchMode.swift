import Foundation

enum SandboxLaunchMode {
    case legacyHost
    case showcase
    case stressChat
    case deeplink

    init(arguments: [String]) {
        if arguments.contains("--stress-chat") {
            self = .stressChat
        } else if arguments.contains("--showcase") {
            self = .showcase
        } else if arguments.contains("--deeplink") {
            self = .deeplink
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
        case .showcase, .stressChat:
            return true
        }
    }

    /// Shortens the mock chunk delay so a UI run does not wait on simulated
    /// streaming.
    var usesFastStreaming: Bool {
        switch self {
        case .legacyHost:
            return false
        case .showcase, .stressChat, .deeplink:
            return true
        }
    }

    var initialPrompt: String? {
        switch self {
        case .legacyHost:
            return nil
        case .showcase:
            return "showcase all bubbles"
        case .stressChat:
            return "stress conversation"
        case .deeplink:
            return "deeplink hand-off"
        }
    }
}
