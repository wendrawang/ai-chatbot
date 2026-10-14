import Foundation

enum SandboxLaunchMode {
    case host
    case figma
    case previewBook

    init(arguments: [String]) {
        if arguments.contains("--previewbook") {
            self = .previewBook
        } else {
            self = arguments.contains("--host") ? .host : .figma
        }
    }
}
