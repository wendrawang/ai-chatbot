import Foundation

/// A picture with a line of copy under it - a promo card, mostly.
///
/// The image is fetched by URL rather than carried in the payload: a banner
/// changes on the bank's schedule, not the app's release schedule, and a
/// base64 image would be copied into every stored conversation.
public struct TanyaAIImagePayload: Equatable {
    /// Nil when the backend sent something that is not a usable URL. The
    /// bubble then shows the caption alone rather than an error: the sentence
    /// is the message, and the picture only illustrates it.
    public let imageURL: URL?

    /// The copy under the picture.
    public let caption: String

    /// Width divided by height.
    ///
    /// Reserves the row's height before the image arrives. Without it the row
    /// grows when the download lands and the conversation jumps under the
    /// customer's eyes - the same reflow that made restored history blink.
    public let aspectRatio: Double

    /// What the picture shows, for VoiceOver. Nil means the picture carries no
    /// information the caption does not already give, and is hidden.
    public let accessibilityText: String?

    /// Used when the backend does not say. Wide enough that a banner looks
    /// deliberate, and close enough to most promo artwork that the correction
    /// on arrival is small.
    public static let defaultAspectRatio: Double = 16.0 / 9.0

    public init(
        imageURL: URL?,
        caption: String,
        aspectRatio: Double = TanyaAIImagePayload.defaultAspectRatio,
        accessibilityText: String? = nil
    ) {
        self.imageURL = imageURL
        self.caption = caption
        // A backend that sends zero or a negative ratio would collapse the row
        // to nothing, so it is treated as not having said.
        self.aspectRatio = aspectRatio > 0
            ? aspectRatio
            : TanyaAIImagePayload.defaultAspectRatio
        self.accessibilityText = accessibilityText
    }
}
