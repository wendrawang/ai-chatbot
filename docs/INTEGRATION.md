# Host application integration

## Entry point

The package requires iOS 16 or newer and exposes one SwiftUI entry point.
The host keeps its own lifecycle: SwiftUI `App` or the classic
`AppDelegate` and `SceneDelegate` pair both work.

```swift
TanyaAIModule.makeView(
    configuration: configuration,
    dependencies: dependencies,
    onClose: closeHandler
)
```

`TanyaAIModule` is a factory, not a singleton. Create one feature graph per
presentation. The returned `TanyaAIRootView` owns a `StateObject` router, an
independent `NavigationStack`, and a SwiftUI PIN sheet.

## Entry from a legacy navigation hierarchy

Keep Tanya AI out of the existing `NavigationView` and `NavigationLink`
destination graph. Put a `fullScreenCover` at a stable host boundary:

```swift
struct LegacyHostView: View {
    @State private var showsTanyaAI = false
    let dependencies: TanyaAIDependencies

    var body: some View {
        NavigationView {
            Button("Open Tanya AI") {
                showsTanyaAI = true
            }
        }
        .fullScreenCover(isPresented: $showsTanyaAI) {
            TanyaAIModule.makeView(
                dependencies: dependencies,
                onClose: {
                    showsTanyaAI = false
                }
            )
        }
    }
}
```

An existing coordinator may toggle the same binding through an observable
presentation gateway. It must not keep a global singleton or build the feature
inside a destination dictionary. The sandbox UI test verifies that legacy
navigation position and local state survive open and close.

## Entry from a UIKit AppDelegate and SceneDelegate host

The package needs SwiftUI, not the SwiftUI `App` lifecycle. An application that
still boots through `AppDelegate` and `SceneDelegate` keeps that lifecycle and
hosts the feature inside a `UIHostingController`:

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var presentationGateway: TanyaAIPresentationGateway?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let gateway = TanyaAIPresentationGateway(
            dependencies: dependencies,
            configuration: configuration
        )
        presentationGateway = gateway

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(
            rootView: LegacyRootScreen(tanyaAIPresenter: gateway)
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
```

The scene owns the gateway, so the observable presentation state lives exactly
as long as the window. A pure UIKit screen can present the feature instead:

```swift
let controller = UIHostingController(
    rootView: TanyaAIModule.makeView(
        configuration: configuration,
        dependencies: dependencies,
        onClose: { [weak self] in
            self?.dismiss(animated: true)
        }
    )
)
controller.modalPresentationStyle = .fullScreen
present(controller, animated: true)
```

Requirements for this path:

- keep `UIApplicationSceneManifest` in `Info.plist` pointing at the scene
  delegate class;
- create one hosting controller per presentation, never a shared instance;
- keep the hosting controller out of the legacy `UINavigationController` stack
  so the feature's own `NavigationStack` stays independent;
- keep UIKit in the host only. The package sources stay free of UIKit,
  `UIViewRepresentable`, and hosting controllers.

## Host actions and deeplinks

An action card, or a confirmation carrying `handoff`, reports a deeplink to
the host instead of navigating:

```swift
TanyaAIModule.makeView(
    configuration: configuration,
    dependencies: dependencies,
    onClose: { showsTanyaAI = false },
    onAction: { action in
        deeplinkRouter.handle(action)
    }
)
```

`TanyaAIAction` carries `identifier` and `deeplink` — the full string the
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

What the link means past that — which screen, which parameters — belongs to
the deeplink handler the app already has. A second parser here would only
drift from it. Worked examples in
[`Examples/NavigationViewHost/Deeplink`](../Examples/NavigationViewHost/Deeplink).

Reuse the validation your existing deeplink handler already performs rather
than writing a second parser. Without it a response could point at another
app, at a web page, or at a screen you never meant to reach from chat.

### What lives where

| Layer | Responsibility |
| --- | --- |
| Backend | Sends `content.actions`, or `handoff` on a confirmation, with the deeplink string |
| Package (SDK) | Renders the buttons and reports the deeplink through `onAction`. Nothing else — no parsing, no opening, no dismissal |
| Host app | Checks the scheme and entry host, closes the feature, then hands the URL to its existing deeplink handler |

Nothing in the package needs changing to adopt this, and nothing needs
reimplementing in the host: parsing the deeplink, mapping it to a screen, and
returning to the dashboard are what the app's existing handler already does.
The work is the `onAction` handler and the sequencing below.

The feature does not close itself when an action fires. Sequence it in the
host, because a full-screen presentation cannot push anything underneath
itself:

1. keep the destination pending;
2. dismiss the feature;
3. once the dismissal finishes, return to the dashboard (or whatever root the
   deeplink expects);
4. then push the destination.

In SwiftUI that means delivering the destination from `fullScreenCover`'s
`onDismiss`, not straight after setting the binding to `false`. Popping and
pushing in the same runloop tick also fights the navigation animation, so let
the pop settle first:

```swift
.fullScreenCover(isPresented: $presenter.isPresented, onDismiss: {
    guard router.hasPendingDestination else { return }
    let isPopping = isDetailActive
    isDetailActive = false
    // NavigationView drops a push that starts while a pop is still animating.
    DispatchQueue.main.asyncAfter(deadline: .now() + (isPopping ? 0.35 : 0)) {
        router.deliverPendingDestination()
    }
}) {
    presenter.makeView()
}
```

A deeplink can also arrive with nothing presented — a cold start, or a push
notification tapped from the dashboard. There is no dismissal to wait for
then, so the host must deliver it directly instead of waiting on `onDismiss`.

Two ways to reach the destination, both valid:

- **Round-trip through the URL.** Build the deeplink URL from the route and
  call `UIApplication.shared.open`. The app re-enters through
  `scene(_:openURLContexts:)`, so the hand-off runs the same code path a push
  notification or another app would. `Info.plist` must declare the scheme in
  `CFBundleURLTypes`. This is what `TanyaAISandboxApp` does.
- **Call the router directly.** Skip the URL and invoke the same function the
  deeplink handler calls. Fewer moving parts and easier to test; use it when
  the round trip buys nothing.

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

Before that, check the deeplink alone —
`xcrun simctl openurl booted "ocbcid://mobile?type=transfer"`. If the URL does
not open the screen on its own, the hand-off cannot either; the usual cause is
a scheme missing from `CFBundleURLTypes`, which makes `UIApplication.open`
fail silently.

## Streaming adapter

Implement `TanyaAIStreamingTransport` in the host. Translate the relative
request into the host request type and execute it with the existing secure
session. The adapter must inherit mTLS, server trust, certificate pinning,
headers, authentication, token refresh, timeout, tracing, and logging policy.

The package owns the SSE framing and response schema. Never inject certificates,
tokens, absolute internal hosts, or a network-session implementation.

## Authorization adapter

Implement `TanyaAIAuthorizationService` in the host. The package owns the
numeric PIN sheet and short-lived input state. The host owns secure
authorization, transaction execution, retry and lockout policy, and error
mapping.

Prefer a host-defined secure PIN container when available. Never persist or log
the PIN. It must not enter chat messages, prompts, analytics, traces, crash
reports, the clipboard, or local storage.

## Theme adapter

Inject `TanyaAITheme` once at the composition boundary. The public theme uses
SwiftUI `Color` and `Font`, so the package stays UIKit-free:

```swift
let theme = TanyaAITheme(
    colors: TanyaAIColors(
        background: CoreColors.background,
        surface: CoreColors.surface,
        primaryText: CoreColors.primaryText,
        secondaryText: CoreColors.secondaryText,
        accent: CoreColors.accent,
        userBubble: CoreColors.outgoingBubble,
        userBubbleText: CoreColors.onAccent,
        assistantBubble: CoreColors.incomingBubble,
        assistantBubbleText: CoreColors.primaryText,
        divider: CoreColors.divider,
        chartTrack: CoreColors.chartTrack,
        chartColors: CoreColors.chartSeries,
        success: CoreColors.success,
        warning: CoreColors.warning,
        error: CoreColors.error,
        overlay: CoreColors.overlay
    ),
    fonts: TanyaAIFonts(
        title: CoreFonts.title,
        headline: CoreFonts.headline,
        body: CoreFonts.body,
        subheadline: CoreFonts.subheadline,
        footnote: CoreFonts.footnote,
        caption: CoreFonts.caption,
        amount: CoreFonts.amount,
        button: CoreFonts.button
    )
)
```

If the existing design system exposes `UIColor` or `UIFont`, convert them to
`Color` and `Font` inside the host adapter. Do not import the host design system
from the package.

## Rendering and lifecycle

The chat uses `ScrollViewReader` plus `LazyVStack`, stable message IDs, and one
observable object per row. A dictionary index avoids linear scans as the
conversation grows. Text deltas are batched every 40 ms.

All stored output closures use weak captures. Active stream and authorization
tasks are cancelled during deallocation. Run the lifecycle and 5,000-message
stress tests before integrating a new long-lived callback.

## Isolation rules

- Do not import the host router or coordinator base class into the package.
- Do not put `NavigationView`, `NavigationLink`, or UIKit in package sources.
- Do not create a singleton router, transport, or authorization service.
- Do not duplicate mTLS, pinning, or token logic inside the feature.
- Do not render arbitrary backend-defined SwiftUI layouts or actions.
