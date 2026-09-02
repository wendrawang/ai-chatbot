import Foundation

/// Where the customer opened the chat from, and what that screen already knew.
///
/// Opening Tanya AI from the transfer screen should not start an empty
/// conversation: the bot can be told which screen this is and which values are
/// already on it, so the customer does not have to repeat them.
///
/// It is metadata, not a message. It travels with every message the customer
/// sends and never appears as chat content.
///
/// Send the least that makes the answer better. This payload leaves the device
/// and is stored by whoever runs the bot, so no PIN, no token, no full account
/// number, and nothing the customer did not already see on the screen.
public struct TanyaAIContext: Equatable {
    /// Stable identifier of the originating screen, agreed with the bot team,
    /// for example `transfer.form` or `portfolio.detail`.
    public let screen: String

    /// Values already visible on that screen, as strings.
    public let parameters: [String: String]

    /// One short line shown to the customer above the conversation, so what
    /// the bot was told is never hidden from them - for example
    /// "Membahas: Transfer ke Sample Beneficiary".
    ///
    /// Nil hides the chip entirely; the context is still sent.
    public let summary: String?

    public init(
        screen: String,
        parameters: [String: String] = [:],
        summary: String? = nil
    ) {
        self.screen = screen
        self.parameters = parameters
        self.summary = summary
    }

    /// The wire form: `{"screen": "...", "parameters": {...}}`.
    ///
    /// `summary` stays on the device. It exists for the customer, not for the
    /// bot, and sending it would duplicate what `parameters` already says.
    public var payload: [String: Any] {
        var payload: [String: Any] = ["screen": screen]
        if parameters.isEmpty == false {
            payload["parameters"] = parameters
        }
        return payload
    }
}
