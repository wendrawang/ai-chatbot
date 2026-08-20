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
