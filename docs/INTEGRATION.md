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

## Host actions and deeplinks

An action card, or a confirmation carrying `handoff`, reports a deeplink to
the host instead of navigating:

```swift
let controller = TanyaAIModule.makeViewController(
    configuration: configuration,
    dependencies: dependencies,
    onAction: { action in
        deeplinkBridge.handle(action)
    }
)
controller.modalPresentationStyle = .fullScreen
present(controller, animated: true)
```

`TanyaAIAction` carries `identifier` and `deeplink` - the full string the
backend sent, such as `ocbcid://mobile?type=transfer`. The package does not
parse it, and `identifier` is for accessibility identifiers and analytics, not
for routing.

Check that the link belongs to the app before opening it. Two checks are
enough, and deliberately the whole of it:

```swift
guard let url = URL(string: action.deeplink),
      url.scheme == "ocbcid",   // rejects https, tel, and other apps
      url.host == "mobile"      // the app's deeplink entry point
else {
    return          // not something this app opens: do nothing
}
existingDeeplinkHandler.open(url)
```

What the link means past that - which screen, which parameters - belongs to
the deeplink handler the app already has. A second parser here would only
drift from it.

### What lives where

| Layer | Responsibility |
| --- | --- |
| Backend | Sends `content.actions`, or `handoff` on a confirmation, with the deeplink string |
| Package | Renders the buttons and reports the deeplink through `onAction`. Nothing else - no parsing, no opening, no dismissal |
| Host app | Checks the scheme and entry host, closes the feature, then hands the URL to its existing deeplink handler |

### Sequencing

The feature does not close itself when an action fires, and a deeplink that
navigates while the feature is still on screen is lost. UIKit gives the exact
moment to act on:

```swift
let controller = activeController
activeController = nil
controller?.dismiss(animated: true) {
    existingDeeplinkHandler.open(url)
}
```

Two cases worth handling explicitly:

- **The feature is not on screen.** A deeplink from a cold start or a push
  notification has no dismissal to wait for; deliver it directly.
- **The existing handler does not return to the dashboard by itself.** Do that
  inside the completion, before opening the destination.

Worked examples, minimal and full, are in
[`Examples/NavigationViewHost/Deeplink`](../Examples/NavigationViewHost/Deeplink).

### Testing the hand-off

`MockTanyaAIActionFixture` builds a stream carrying deeplinks you choose, so
the whole path can run without a backend:

```swift
let transport = MockTanyaAIStreamingTransport(
    scenario: .custom(
        MockTanyaAIActionFixture.actionCardChunks(
            buttons: [
                .init(
                    title: "Open transfer",
                    deeplink: "ocbcid://mobile?type=transfer",
                    identifier: "open-transfer"
                )
            ]
        )
    )
)
```

`approvalHandoffChunks(deeplink:)` covers the second entry point, where the
confirmation hands off and the PIN sheet must not appear. Buttons carry
`action.<identifier>` as their accessibility identifier. `TanyaAITestSupport`
belongs to debug and test targets only.

Before that, check the deeplink alone -
`xcrun simctl openurl booted "ocbcid://mobile?type=transfer"`. If the URL does
not open the screen on its own, the hand-off cannot either; the usual cause is
a scheme missing from `CFBundleURLTypes`, which makes `UIApplication.open`
fail silently.

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
