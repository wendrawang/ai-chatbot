import Foundation

extension CopyCatalog {
    func design(_ key: String, values: [String: String] = [:]) -> String {
        text(key, bundle: .module, values: values)
    }
}
