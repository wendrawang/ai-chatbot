import Foundation

enum DesignCopy {
    static func text(_ key: String) -> String {
        NSLocalizedString(key, bundle: .module, comment: "Component label")
    }
}
