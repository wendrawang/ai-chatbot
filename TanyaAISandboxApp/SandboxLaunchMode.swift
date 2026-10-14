import Foundation

enum SandboxLaunchMode {
    case host
    case figma

    init(arguments: [String]) {
        self = arguments.contains("--host") ? .host : .figma
    }
}
