# Host application integration

## Entry point

The host creates the feature using `TanyaAIModule.makeViewController`. Present
the returned controller full screen so the feature owns an isolated UIKit
navigation stack.

Create the controller from an imperative presentation gateway, not from a
SwiftUI `body` and not from a legacy `NavigationLink`. The gateway keeps weak
references to the root presenter and active feature controller. Create one
gateway per scene and inject it into the existing coordinator or ViewModel
action boundary. The sandbox default screen demonstrates this handoff and
verifies that the legacy stack and screen state survive dismissal.

## Streaming adapter

Implement `TanyaAIStreamingTransport` in the host application. The adapter
translates `TanyaAIStreamRequest` into the host's request type and executes it
with the existing authenticated session. It should inherit the host's mTLS,
server trust, certificate pinning, headers, token refresh, timeout, tracing, and
logging policy.

The package parses the streamed bytes and owns the backend event schema. It
does not receive certificates, tokens, hosts, or network-session objects.

## Authorization adapter

Implement `TanyaAIAuthorizationService` in the host application. The package
owns the PIN bottom-sheet UI and short-lived input state. The adapter owns
secure authorization, transaction execution, retry policy, and error mapping.

Prefer a secure host-defined PIN container if one exists. Never persist or log
the PIN. Clear input immediately after submission and dismissal.

## Theme adapter

The host must inject `TanyaAITheme`. There are no production color or font
defaults inside the feature. Map existing host design tokens once at the
composition boundary:

```swift
let theme = TanyaAITheme(
    colors: TanyaAIColors(
        background: CorePalette.background,
        surface: CorePalette.surface,
        primaryText: CorePalette.primaryText,
        secondaryText: CorePalette.secondaryText,
        accent: CorePalette.accent,
        userBubble: CorePalette.chatOutgoing,
        userBubbleText: CorePalette.onAccent,
        assistantBubble: CorePalette.chatIncoming,
        assistantBubbleText: CorePalette.primaryText,
        divider: CorePalette.divider,
        chartTrack: CorePalette.chartTrack,
        chartColors: CorePalette.chartSeries,
        success: CorePalette.success,
        warning: CorePalette.warning,
        error: CorePalette.error,
        overlay: CorePalette.overlay
    ),
    fonts: TanyaAIFonts(
        title: CoreTypography.title,
        headline: CoreTypography.headline,
        body: CoreTypography.body,
        subheadline: CoreTypography.subheadline,
        footnote: CoreTypography.footnote,
        caption: CoreTypography.caption,
        amount: CoreTypography.amount,
        button: CoreTypography.button
    )
)
```

The names above are placeholders. The sandbox never imports or mirrors a host
design-system implementation.

## Rendering and performance

The chat uses a separator-free `UITableView` with reusable hosting cells.
Destinations are created lazily by the UIKit coordinator. Streamed text is
batched and each message owns stable observable state, so one text delta does
not rebuild the full conversation.

Automated checks cover request cancellation on deallocation, PIN ViewModel
deallocation, one-thousand-event parser throughput, and a 120-message scroll
frame-rate sample. Real-device Instruments runs remain mandatory before a
production release because simulator results are directional only.

## Isolation

The feature does not import the host router, coordinator base classes, or
networking implementation. External host navigation can be added later through
another narrow protocol without changing internal navigation.
