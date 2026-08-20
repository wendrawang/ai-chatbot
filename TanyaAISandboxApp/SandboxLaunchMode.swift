import Foundation

enum SandboxLaunchMode {
    case legacyHost
    case showcase
    case stressChat

    init(arguments: [String]) {
        if arguments.contains("--stress-chat") {
            self = .stressChat
        } else if arguments.contains("--showcase") {
            self = .showcase
        } else {
            self = .legacyHost
        }
    }

    var isStandaloneFeature: Bool {
        switch self {
        case .legacyHost:
            return false
        case .showcase, .stressChat:
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
        }
    }
}
