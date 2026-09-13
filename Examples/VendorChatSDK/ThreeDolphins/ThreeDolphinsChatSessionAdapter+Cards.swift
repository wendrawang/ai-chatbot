import Foundation
import TanyaAI
import imi_dolphin_livechat_ios

/// Where a typed bubble would cross the channel - if it can.
///
/// Everything else in this adapter is a translation of something the docs
/// describe. This file is the one part built on an assumption, and it is the
/// assumption the whole typed-bubble system rests on, so it lives alone where
/// it can be rewritten without touching the live path.
///
/// 3Dolphins publishes no equivalent of Sendbird's `custom_type` + `data`.
/// The only candidate is `dataUser: AnyObject?` on `onSendMessage`, which is
/// undocumented, never used in any example, and may well be outbound-only
/// profile enrichment rather than a general envelope. See the README.
extension ThreeDolphinsChatSessionAdapter {
    /// Event names the package renders, as sent by the bot.
    static let cardNamePrefix = "content."

    /// A live message carrying one of the package's typed cards.
    ///
    /// Returns nil today for every message, because nothing is known to carry
    /// the payload. It is written out rather than left as a `TODO` so the
    /// shape of the answer is already decided: a name and its `data` object,
    /// passed through untouched.
    func structuredPayload(
        in message: DolphinMessage
    ) -> (name: String, json: Data)? {
        // CHECK: the whole of this function. If `dataUser` round-trips, read
        // it here. If it does not, the fallback is a fenced block inside the
        // message text - see `card(inText:)` below, which needs no field at
        // all and costs the payload being visible in any other client.
        nil
    }

    /// The same question for a row of history.
    func structuredPayload(
        inHistoryRow row: [String: Any]
    ) -> (name: String, json: Data)? {
        // CHECK: mirrors `structuredPayload(in:)`. Whatever carries a card
        // live has to survive into the history response too, or a reopened
        // conversation loses every card it ever showed.
        _ = row
        return nil
    }

    /// The fallback, if no metadata field turns out to exist.
    ///
    /// The bot wraps the event in a fenced block and the adapter lifts it out.
    /// It works on any transport that carries text, which is its only virtue:
    /// the raw JSON is visible to every other client that opens the same
    /// conversation, and to anyone reading the vendor's dashboard.
    ///
    /// Unused until the question above is settled. Kept here so the decision
    /// is between two written things rather than between one and an idea.
    func card(inText text: String) -> (name: String, json: Data)? {
        let fence = "```tanyaai"
        guard let start = text.range(of: fence),
              let end = text.range(
                of: "```",
                range: start.upperBound..<text.endIndex
              ) else {
            return nil
        }
        let body = text[start.upperBound..<end.lowerBound]
        guard let json = body.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: json)
                as? [String: Any],
              let name = object["event"] as? String,
              name.hasPrefix(Self.cardNamePrefix),
              let data = object["data"],
              let payload = try? JSONSerialization.data(withJSONObject: data)
        else {
            return nil
        }
        return (name, payload)
    }
}
