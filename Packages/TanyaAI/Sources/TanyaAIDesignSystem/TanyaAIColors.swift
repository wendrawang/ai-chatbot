import SwiftUI

public struct TanyaAIColors {
    public let background: Color
    public let surface: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let accent: Color
    public let userBubble: Color
    public let userBubbleText: Color
    public let assistantBubble: Color
    public let assistantBubbleText: Color
    public let divider: Color
    public let chartTrack: Color
    public let chartColors: [Color]
    public let success: Color
    public let warning: Color
    public let error: Color
    public let overlay: Color

    public init(
        background: Color,
        surface: Color,
        primaryText: Color,
        secondaryText: Color,
        accent: Color,
        userBubble: Color,
        userBubbleText: Color,
        assistantBubble: Color,
        assistantBubbleText: Color,
        divider: Color,
        chartTrack: Color,
        chartColors: [Color] = [],
        success: Color,
        warning: Color,
        error: Color,
        overlay: Color
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
        self.chartColors = chartColors.isEmpty ? [accent] : chartColors
        self.success = success
        self.warning = warning
        self.error = error
        self.overlay = overlay
    }
}
