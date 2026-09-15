# Integrating Tanya AI into a host app

Six steps. The first four can be done before any chat backend exists - step 3
ships a mock that answers on its own, so the whole screen can be built and
reviewed while the vendor question is still open.

The feature is **presented, never pushed**. It is its own view controller and
never enters the host's navigation stack, which is what keeps it clear of a
`NavigationView` that drops pushes started during a pop. Only the animation
imitates a push.

---

## 1. Add the packages

Two local packages. `TanyaAI` is the feature; `DesignKit` is the design system
it draws with, kept separate so it can be reused by something else later.

```
Packages/
  DesignKit/     ← Package.swift
  TanyaAI/       ← Package.swift, depends on ../DesignKit
```

In Xcode: **File → Add Package Dependencies → Add Local**, choose
`Packages/TanyaAI`. DesignKit comes with it.

Link two products into the app target:

| Product | Configuration |
| --- | --- |
| `TanyaAI` | All |
| `TanyaAITestSupport` | **Debug only** |

`TanyaAITestSupport` contains fabricated answers, including confirmation
cards. Shipping it puts a code path in production that can draw an invented
transfer approval. Keep it out of Release and guard its imports with
`#if DEBUG`.

---

## 2. Build a theme

Everything drawn takes its colours and type from here, so the feature looks
like your app rather than like a sandbox.

```swift
import TanyaAI
import UIKit

enum TanyaAIAppearance {
    static var theme: TanyaAITheme {
        TanyaAITheme(colors: colors, fonts: fonts)
    }

    private static var colors: TanyaAIColors {
        TanyaAIColors(
            background: .systemBackground,
            surface: .secondarySystemBackground,
            primaryText: .label,
            secondaryText: .secondaryLabel,
            accent: .ocbcRed,
            userBubble: .ocbcRed,
            userBubbleText: .white,
            // The reply bubble is outlined, so this is its fill - usually the
            // background colour, with `divider` drawing the edge.
            assistantBubble: .systemBackground,
            assistantBubbleText: .label,
            divider: .separator,
            chartTrack: .tertiarySystemFill,
            chartColors: [.ocbcRed, .systemOrange, .systemBlue, .systemGreen],
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed,
            overlay: UIColor.black.withAlphaComponent(0.45)
        )
    }

    private static var fonts: TanyaAIFonts {
        TanyaAIFonts(
            title: .preferredFont(forTextStyle: .title1),
            headline: .preferredFont(forTextStyle: .headline),
            body: .preferredFont(forTextStyle: .body),
            subheadline: .preferredFont(forTextStyle: .subheadline),
            footnote: .preferredFont(forTextStyle: .footnote),
            caption: .preferredFont(forTextStyle: .caption1),
            amount: .preferredFont(forTextStyle: .title2),
            button: .preferredFont(forTextStyle: .headline)
        )
    }
}
```

Use `UIFontMetrics`-scaled fonts, as above, so Dynamic Type keeps working.

---

## 3. Provide a session

`TanyaAIChatSession` is the only seam to a backend. Four members:

```swift
public protocol TanyaAIChatSession: AnyObject {
    var onEvent: ((TanyaAIChatSessionEvent) -> Void)? { get set }
    func connect()
    func send(text: String, context: TanyaAIContext?, requestIdentifier: String)
    func disconnect()
}
```

### Start with the mock

Nothing else in this guide depends on a real backend.

```swift
#if DEBUG
import TanyaAITestSupport
#endif

let makeSession: () -> TanyaAIChatSession = {
    MockTanyaAIChatSession.sandbox()
}
```

It answers on keywords: `showcase` draws every bubble, `transfer` opens a
confirmation, `deeplink` offers hand-off links, `spending` a chart. Anything
else returns a portfolio.

### Then the vendor

Reference adapters live in `Examples/VendorChatSDK/`. Whichever you write, the
rules are the same:

- **Emit `.connected` last**, after history has been read. It means "the
  conversation is settled". Sent first, a greeting appears and history then
  replaces it, which is the flicker this ordering exists to prevent.
- **Always close a turn** with `.messageCompleted`. Without it the typing
  indicator spins forever and the send button stays as Stop.
- **`makeSession` must return a new instance per presentation.** The feature
  takes ownership of `onEvent` and closes the session on dismissal, so a
  shared instance is dead by the second presentation.

---

## 4. Authorize a PIN

Only needed if confirmations are completed inside the chat. Skip it and any
confirmation without a `handoff` is refused in the open rather than showing a
button that quietly does nothing.

```swift
final class TanyaAIAuthorization: TanyaAIAuthorizationService {
    @discardableResult
    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (Result<TanyaAIAuthorizationResult, Error>) -> Void
    ) -> TanyaAICancellable {
        let task = api.authorize(
            transactionId: request.transactionIdentifier,
            challengeId: request.challengeIdentifier,
            pin: pin
        ) { result in
            completion(result.map {
                TanyaAIAuthorizationResult(
                    transactionIdentifier: request.transactionIdentifier,
                    status: $0.isPending ? .processing : .completed
                )
            })
        }
        return task
    }
}
```

The package collects the PIN, hands it to you, and keeps nothing. **Do not
log it, persist it, or copy it anywhere** - including crash reporters and
analytics.

---

## 5. Compose the host

One host per signed-in session. Build it where your session-scoped
dependencies live, not inside a view.

```swift
import TanyaAI

final class TanyaAIComposition {
    private let authorization = TanyaAIAuthorization()

    func makeHost(onDeeplink: @escaping (URL) -> Void) -> TanyaAIHost {
        TanyaAIHost(
            theme: TanyaAIAppearance.theme,
            authorizationService: authorization,
            deeplinkScheme: "ocbcid",
            deeplinkHost: "mobile",
            makeSession: { MockTanyaAIChatSession.sandbox() },
            onDeeplink: onDeeplink
        )
    }
}
```

`deeplinkScheme` and `deeplinkHost` are a filter, not a router. A deeplink
that does not match is dropped before it reaches you, so a bot cannot ask the
app to open something outside its own scheme.

---

## 6. Attach and present

`TanyaAIHost` is an `ObservableObject`, so it can be held in a view and
injected downward.

```swift
struct RootScreen: View {
    @StateObject private var tanyaAI = TanyaAIComposition()
        .makeHost { url in AppRouter.shared.open(url) }

    var body: some View {
        NavigationView {
            List {
                Button("Tanya AI") { tanyaAI.present() }
            }
        }
        .tanyaAIHost(tanyaAI)
    }
}
```

`.tanyaAIHost(_:)` places an invisible, zero-sized controller in the hierarchy
for the feature to be presented from. Apply it **once**, on the screen that
owns the host — not on every screen that opens it.

### Where to put it in a NavigationView app

Apply it to the screen that owns the host, inside the `NavigationView`. The
feature does not join the stack, so the anchor's position only decides which
controller presents it.

---

## Deeplinks

When the customer taps a hand-off link, the feature **closes first, then**
calls `onDeeplink`. That order matters: a destination opened while the modal
is still animating away is lost silently.

Your `onDeeplink` receives a `URL` that already passed the scheme and host
filter. Validate the rest - path, parameters, entitlements - as you would for
any incoming link.

---

## Optional: tell the bot where the chat was opened from

```swift
tanyaAI.present()
// Opening from a transfer screen, so the bot does not ask what the
// screen already knows:
let context = TanyaAIContext(
    screen: "transfer.form",
    parameters: ["currency": "IDR"],
    summary: "Membahas: Transfer"
)
```

`summary` is shown to the customer so what the bot was told is never hidden
from them. It stays on the device; only `screen` and `parameters` are sent.

**Send the least that makes the answer better.** This payload leaves the
device and is stored by whoever runs the bot: no PIN, no token, no full
account number, nothing the customer cannot already see.

---

## Before shipping

- [ ] `TanyaAITestSupport` is not linked in Release
- [ ] `makeSession` returns a **new** instance each time
- [ ] The bot always sends `response.completed`
- [ ] PIN is never logged, persisted or sent to analytics
- [ ] `onDeeplink` validates beyond the scheme filter
- [ ] Dynamic Type checked at the largest accessibility size
- [ ] Dark mode checked - the theme supplies both

---

## Where things live

| I want to… | Look at |
| --- | --- |
| Know what JSON draws a bubble | `docs/BUBBLE_SCHEMA.md` |
| See every bubble running | `./Scripts/run_sandbox.sh --showcase` |
| Copy an adapter | `Examples/VendorChatSDK/` |
| Change a colour or spacing | `Packages/DesignKit/Sources/DesignKit/Tokens/` |
