import UIKit

public struct TanyaAIColors {
    public let background: UIColor
    public let surface: UIColor
    public let primaryText: UIColor
    public let secondaryText: UIColor
    public let accent: UIColor
    public let userBubble: UIColor
    public let userBubbleText: UIColor
    public let assistantBubble: UIColor
    public let assistantBubbleText: UIColor
    public let divider: UIColor
    public let chartTrack: UIColor
    public let success: UIColor
    public let warning: UIColor
    public let error: UIColor
    public let overlay: UIColor

    public init(
        background: UIColor,
        surface: UIColor,
        primaryText: UIColor,
        secondaryText: UIColor,
        accent: UIColor,
        userBubble: UIColor,
        userBubbleText: UIColor,
        assistantBubble: UIColor,
        assistantBubbleText: UIColor,
        divider: UIColor,
        chartTrack: UIColor,
        success: UIColor,
        warning: UIColor,
        error: UIColor,
        overlay: UIColor
    ) {
        self.background = background
        self.surface = surface
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.accent = accent
        self.userBubble = userBubble
        self.userBubbleText = userBubbleText
        self.assistantBubble = assistantBubble
        self.assistantBubbleText = assistantBubbleText
        self.divider = divider
        self.chartTrack = chartTrack
        self.success = success
        self.warning = warning
        self.error = error
        self.overlay = overlay
    }
}
