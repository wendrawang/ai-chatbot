import Foundation

/// A value supplied by the host, scoped to one view tree or feature presentation.
/// Overrides use stable namespaced keys. Values may contain named placeholders
/// such as {count}; they are never treated as printf format strings.
public struct CopyCatalog: Equatable {
    public let localeIdentifier: String
    public let overrides: [String: String]

    public init(
        localeIdentifier: String = Locale.preferredLanguages.first ?? "en",
        overrides: [String: String] = [:]
    ) {
        self.localeIdentifier = localeIdentifier
        self.overrides = overrides
    }

    public func text(
        _ key: String,
        bundle: Bundle,
        values: [String: String] = [:]
    ) -> String {
        let template = overrides[key] ?? localized(key, bundle: bundle)
        guard !values.isEmpty else { return template }
        // Replace placeholders in the original template only. An injected value
        // containing another placeholder must remain literal content.
        return template.components(separatedBy: "{").enumerated().map { index, part in
            guard index > 0 else { return part }
            guard let closing = part.firstIndex(of: "}") else { return "{" + part }
            let name = String(part[..<closing])
            guard let value = values[name] else { return "{" + part }
            return value + part[part.index(after: closing)...]
        }.joined()
    }

    private func localized(_ key: String, bundle: Bundle) -> String {
        let language = Bundle.preferredLocalizations(
            from: bundle.localizations, forPreferences: [localeIdentifier]
        ).first ?? "en"
        let fallback = localizedBundle("en", in: bundle)?.localizedString(forKey: key, value: key, table: nil) ?? key
        return localizedBundle(language, in: bundle)?.localizedString(forKey: key, value: fallback, table: nil)
            ?? fallback
    }

    private func localizedBundle(_ language: String, in bundle: Bundle) -> Bundle? {
        bundle.path(forResource: language, ofType: "lproj").flatMap(Bundle.init(path:))
    }
}
