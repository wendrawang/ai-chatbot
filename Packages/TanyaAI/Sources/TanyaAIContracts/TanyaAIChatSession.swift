import Foundation

/// A vendor chat SDK acting as the transport.
///
/// The SSE transport is request-shaped: one request, a stream of chunks, a
/// completion. A live-chat SDK is session-shaped: connect once, then send and
/// receive on an open channel, including messages nobody asked for — an agent
/// replying, a queue update, a reconnect.
///
/// The host implements this over the vendor SDK. The package owns the chat UI
/// and never imports the vendor.
public protocol TanyaAIChatSession: AnyObject {
    /// Set by the package before `connect()`. Every event the session produces
    /// arrives here; delivery may be on any queue.
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)? { get set }

    /// Opens the channel. Called once, when the feature appears.
    func connect()

    /// Sends one customer message.
    ///
    /// - Parameters:
    ///   - context: where the chat was opened from, or nil once the customer
    ///     clears it. Pass it to the vendor as metadata - most SDKs have a
    ///     custom-data field for exactly this - never as visible chat text.
    ///   - requestIdentifier: correlates the reply with this turn when the
    ///     vendor echoes an identifier back. Adapters that cannot correlate
    ///     may ignore it: the package falls back to the message identifier the
    ///     vendor supplies.
    func send(
        text: String,
        context: TanyaAIContext?,
        requestIdentifier: String
    )

    /// Closes the channel. Called when the feature is released.
    func disconnect()
}

/// What a session reports back.
///
/// The vendor's own payload shape stays in the host adapter. By the time an
/// event reaches the package it is already one of these.
public enum TanyaAIChatSessionEvent {
    /// The channel is open and ready to accept messages.
    case connected

    /// The channel closed. A non-nil error means it closed unexpectedly.
    case disconnected(Error?)

    /// An assistant or agent reply is starting.
    case messageStarted(messageIdentifier: String)

    /// Text for a reply, whole or partial. Adapters that receive complete
    /// messages send one delta and then `messageCompleted`.
    case messageDelta(messageIdentifier: String, text: String)

    /// A reply finished. Ends the turn the package is waiting on.
    case messageCompleted(messageIdentifier: String)

    /// A typed card, in the package's own event schema.
    ///
    /// - Parameters:
    ///   - name: event name, such as `content.approval` or `content.actions`.
    ///   - json: the event's `data` object, as sent by the bot.
    ///
    /// This is what keeps the typed bubbles working over a vendor channel: the
    /// bot embeds the same JSON it would have streamed over SSE, and the
    /// adapter passes it through untouched.
    case structuredPayload(name: String, json: Data)

    /// The agent or bot is composing.
    case typing(Bool)

    /// A hand-off the channel asked for, rather than a button on a card.
    ///
    /// Use this when the vendor's own message format carries the deeplink. The
    /// package does not render it; it reports it to the host through the same
    /// `onAction` handler a card would use, so the host has one exit point
    /// whichever side the action came from.
    case hostAction(identifier: String, deeplink: String)

    /// The session failed. Ends the current turn with an error.
    case failed(Error)
}
