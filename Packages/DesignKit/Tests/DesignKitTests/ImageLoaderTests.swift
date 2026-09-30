import UIKit
import XCTest
@testable import DesignKit

final class ImageLoaderTests: XCTestCase {
    func testLargeImageIsDownsampledBeforeDisplay() throws {
        let fileURL = try makeImageFile(size: CGSize(width: 2_048, height: 1_024))
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let image = try XCTUnwrap(ImageLoader.thumbnail(at: fileURL))
        let bitmap = try XCTUnwrap(image.cgImage)

        XCTAssertEqual(bitmap.width, 1_024)
        XCTAssertEqual(bitmap.height, 512)
        XCTAssertLessThanOrEqual(bitmap.bytesPerRow * bitmap.height, 4 * 1_024 * 1_024)
    }

    func testSmallImageIsNotUpscaled() throws {
        let fileURL = try makeImageFile(size: CGSize(width: 80, height: 40))
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let image = try XCTUnwrap(ImageLoader.thumbnail(at: fileURL))

        XCTAssertEqual(image.size, CGSize(width: 80, height: 40))
    }

    func testInvalidDataKeepsThePlaceholder() throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: fileURL) }
        try Data("Not an image".utf8).write(to: fileURL)

        XCTAssertNil(ImageLoader.thumbnail(at: fileURL))
    }

    private func makeImageFile(size: CGSize) throws -> URL {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let data = renderer.jpegData(withCompressionQuality: 0.8) { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try data.write(to: fileURL)
        return fileURL
    }
}
