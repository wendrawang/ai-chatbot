import Foundation
import XCTest
@testable import DesignKit

final class CopyCatalogTests: XCTestCase {
    private var fixtureURL: URL!
    private var fixture: Bundle!

    override func setUpWithError() throws {
        fixtureURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString).appendingPathExtension("bundle")
        try FileManager.default.createDirectory(at: fixtureURL, withIntermediateDirectories: true)
        let info: [String: Any] = [
            "CFBundleIdentifier": UUID().uuidString,
            "CFBundleDevelopmentRegion": "en",
            "CFBundleLocalizations": ["en", "id"]
        ]
        let data = try PropertyListSerialization.data(fromPropertyList: info, format: .xml, options: 0)
        try data.write(to: fixtureURL.appendingPathComponent("Info.plist"))
        try write("\"title\" = \"Message\";\n\"fallback\" = \"Fallback\";", language: "en")
        try write("\"title\" = \"Pesan\";", language: "id")
        fixture = try XCTUnwrap(Bundle(url: fixtureURL))
    }

    override func tearDownWithError() throws {
        fixture = nil
        if let fixtureURL { try FileManager.default.removeItem(at: fixtureURL) }
        fixtureURL = nil
    }

    func testRegionalLocaleResolvesLanguage() {
        XCTAssertEqual(CopyCatalog(localeIdentifier: "id-ID").text("title", bundle: fixture), "Pesan")
    }

    func testEnglishAndIndonesianRemainIndependent() {
        let english = CopyCatalog(localeIdentifier: "en")
        let indonesian = CopyCatalog(localeIdentifier: "id")
        XCTAssertEqual(english.text("title", bundle: fixture), "Message")
        XCTAssertEqual(indonesian.text("title", bundle: fixture), "Pesan")
        XCTAssertEqual(english.text("title", bundle: fixture), "Message")
    }

    func testUnsupportedLanguageFallsBackToEnglish() {
        XCTAssertEqual(CopyCatalog(localeIdentifier: "fr").text("title", bundle: fixture), "Message")
    }

    func testMissingTranslationFallsBackToEnglish() {
        XCTAssertEqual(CopyCatalog(localeIdentifier: "id").text("fallback", bundle: fixture), "Fallback")
    }

    func testHostOverridesAndEmptySubtitleWin() {
        let copy = CopyCatalog(overrides: ["title": "Host title", "subtitle": ""])
        XCTAssertEqual(copy.text("title", bundle: fixture), "Host title")
        XCTAssertEqual(copy.text("subtitle", bundle: fixture), "")
    }

    func testNamedValuesAreLiteralAndNeverReinterpreted() {
        let copy = CopyCatalog(overrides: ["message": "{title}: {count}. 100% %@"])
        XCTAssertEqual(copy.text("message", bundle: fixture, values: ["title": "{count}", "count": "2"]),
                       "{count}: 2. 100% %@")
    }

    func testUnknownKeyAndUnresolvedPlaceholderStayVisible() {
        let copy = CopyCatalog(overrides: ["message": "Hello {missing}"])
        XCTAssertEqual(copy.text("missing.key", bundle: fixture), "missing.key")
        XCTAssertEqual(copy.text("message", bundle: fixture), "Hello {missing}")
    }

    func testEqualityIncludesLanguageAndHostOverrides() {
        XCTAssertNotEqual(CopyCatalog(localeIdentifier: "en"), CopyCatalog(localeIdentifier: "id"))
        XCTAssertNotEqual(CopyCatalog(overrides: ["title": "A"]), CopyCatalog(overrides: ["title": "B"]))
    }

    private func write(_ text: String, language: String) throws {
        let directory = fixtureURL.appendingPathComponent("\(language).lproj")
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try text.write(to: directory.appendingPathComponent("Localizable.strings"), atomically: true, encoding: .utf8)
    }
}
