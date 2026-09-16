import Foundation

/// Unique wire names shared by the decoder, host adapters, and fixtures.
public enum TanyaAIEventName: String, CaseIterable {
    case image
    case choices
    case actions
    case html
    case liveAgent = "live_agent"
    case approval
    case receipt
    case chart
    case portfolio
    case financialList = "financial_list"
    case status
    case information
    case suggestions
    case responseStarted = "response_started"
    case textDelta = "text_delta"
    case responseCompleted = "response_completed"
    case heartbeat

    /// Reads older stored messages; new outbound payloads use rawValue.
    public init?(wireName: String) {
        switch wireName {
        case "response.started": self = .responseStarted
        case "text.delta": self = .textDelta
        case "response.completed": self = .responseCompleted
        case "response.suggestions": self = .suggestions
        default:
            let canonical = wireName.hasPrefix("content.")
                ? String(wireName.dropFirst(8)).replacingOccurrences(of: "-", with: "_")
                : wireName
            self.init(rawValue: canonical)
        }
    }

    public var isContent: Bool {
        switch self {
        case .suggestions, .responseStarted, .textDelta, .responseCompleted, .heartbeat:
            return false
        default:
            return true
        }
    }

    /// Unknown flat names are future cards, so their fallback can still be shown.
    public static func isContentName(_ name: String) -> Bool {
        if let event = Self(wireName: name) { return event.isContent }
        return name.hasPrefix("content.") || (!name.isEmpty && !name.contains("."))
    }
}
