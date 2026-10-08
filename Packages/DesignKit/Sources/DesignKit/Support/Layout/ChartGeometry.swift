import Foundation

/// Normalization happens before summing, so large finite values cannot overflow.
enum ChartGeometry {
    static func fractions(_ values: [Double]) -> [Double] {
        let positive = values.map { $0.isFinite ? max(0, $0) : 0 }
        let maximum = positive.max() ?? 0
        guard maximum > 0 else { return positive }
        let normalized = positive.map { $0 / maximum }
        let total = normalized.reduce(0, +)
        return normalized.map { $0 / total }
    }

    static func lineHeights(_ values: [Double]) -> [Double] {
        let finite = values.map { $0.isFinite ? $0 : 0 }
        let magnitude = finite.map(abs).max() ?? 0
        guard magnitude > 0 else { return finite.map { _ in 0.5 } }
        let normalized = finite.map { $0 / magnitude }
        let minimum = normalized.min() ?? 0
        let range = (normalized.max() ?? 0) - minimum
        guard range > 0 else { return finite.map { _ in 0.5 } }
        return normalized.map { ($0 - minimum) / range }
    }
}
