import DesignKit
import Foundation

extension CopyCatalog {
    func chat(_ key: String, values: [String: String] = [:]) -> String {
        text(key, bundle: .module, values: values)
    }
}
