import Foundation
import TanyaAI
// import imi_dolphin_livechat_ios

extension DolphinChatSessionAdapter {
    /// Everything `setupConnection` and `onSendMessage` need.
    struct Configuration {
        let baseUrl: String
        let clientId: String
        /// Spelled as the SDK spells it.
        let clientSecrect: String
        let enableGetQueue: Bool
        /// Base value passed as the SDK's `dataUser` argument.
        let dataUser: [String: Any]
        /// Key the bot reads the screen context from.
        let contextKey: String

        init(
            baseUrl: String,
            clientId: String,
            clientSecrect: String,
            enableGetQueue: Bool = false,
            dataUser: [String: Any] = [:],
            contextKey: String = "appContext"
        ) {
            self.baseUrl = baseUrl
            self.clientId = clientId
            self.clientSecrect = clientSecrect
            self.enableGetQueue = enableGetQueue
            self.dataUser = dataUser
            self.contextKey = contextKey
        }

        /// Merges the screen context into the SDK's custom-data field.
        ///
        /// If your deployment types `dataUser` as something other than a
        /// dictionary, keep the merge here and convert at the call site - the
        /// point is that context leaves as metadata, not as chat text.
        func dataUser(with context: TanyaAIContext?) -> [String: Any] {
            guard let context else {
                return dataUser
            }
            var merged = dataUser
            merged[contextKey] = context.payload
            return merged
        }
    }
}

/// How to read a `DolphinMessage`.
///
/// The SDK documentation names the type but not its fields, so this is the one
/// place to adjust after opening the framework header in Xcode. Three
/// one-liners, for example:
///
///     DolphinMessageMapper(
///         identifier: { $0.messageId ?? UUID().uuidString },
///         text: { $0.message },
///         payload: { $0.payload as? [String: Any] }
///     )
///
/// `payload` may return nil when the deployment cannot attach rich content:
/// the adapter then falls back to reading the JSON envelope out of the text.
struct DolphinMessageMapper {
    let identifier: (DolphinMessage) -> String
    let text: (DolphinMessage) -> String?
    let payload: (DolphinMessage) -> [String: Any]?

    init(
        identifier: @escaping (DolphinMessage) -> String,
        text: @escaping (DolphinMessage) -> String?,
        payload: @escaping (DolphinMessage) -> [String: Any]? = { _ in nil }
    ) {
        self.identifier = identifier
        self.text = text
        self.payload = payload
    }
}
