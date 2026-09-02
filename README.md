# Tanya AI Sandbox

A sanitized iOS 16 reference implementation for a modular conversational
feature. The repository contains only deterministic demo data. It must never
contain production endpoints, certificates, secrets, proprietary source code,
internal identifiers, or customer data.

## Goals

- Run on iOS 16 or newer with typed `NavigationStack` state.
- Stay isolated from a host application's `NavigationView` and
  `NavigationLink` hierarchy.
- Keep every production package view and navigation primitive pure SwiftUI.
- Keep business rules independent from UI and networking.
- Reuse the host application's secure networking and authorization stack.
- Render long conversations without separators between rows.
- Support typed financial cards, dynamic suggestions, and PIN approval.
- Remain testable as the feature grows.

## Quick start

Open `TanyaAISandbox.xcodeproj`, select an iPhone simulator, and run the
`TanyaAISandbox` scheme. The app boots through `AppDelegate` and
`SceneDelegate`, exactly like an existing UIKit-lifecycle host. The initial
screen simulates a legacy SwiftUI navigation hierarchy. Its detail screen opens
Tanya AI as an independent, full-screen SwiftUI feature.

The demo PIN is `123456`. It exists only in the mock authorization service.

Run all local verification:

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/verify.sh
```

Build, install, and launch on a simulator in one step:

```sh
./Scripts/run_sandbox.sh --deeplink
```

Any argument is forwarded to the app, so the launch modes below work directly.
Override the device with `TANYA_AI_SIMULATOR`.

### Launch arguments

`SceneDelegate` reads one optional launch argument through `SandboxLaunchMode`.
Add it in **Edit Scheme → Run → Arguments** to reproduce a UI test locally.

| Argument | Root screen | Initial prompt | Mock chunk delay | Used by |
| --- | --- | --- | --- | --- |
| none | `LegacyRootScreen` | none | 0.04 s | `TanyaAILegacyIntegrationTests` |
| `--showcase` | Tanya AI directly | `showcase all bubbles` | 0.001 s | `TanyaAISandboxScreenshotTests` |
| `--stress-chat` | Tanya AI directly | `stress conversation` | 0.001 s | `TanyaAIStressUITests` |
| `--deeplink` | `LegacyRootScreen` | `deeplink hand-off` | 0.001 s | `TanyaAIDeeplinkUITests` |

`--deeplink` opens on the legacy host and streams an action card plus a
confirmation that hands off. Walk it: **Open legacy detail → Open Tanya AI →
Open transfer form**. The feature closes, the stack returns to Legacy Home, and
the destination is pushed with a back button reading "Legacy Home". The blocked
`https` button does nothing, and Confirm on the hand-off approval never opens
the PIN sheet.

`--showcase` streams `MockTanyaAIShowcaseFixture` in one response: every
confirmation and receipt card, every insight card, the four status levels, the
unsupported-content fallback, and the suggestion strip. It exists so the
screenshot test can scroll each semantic bubble into the viewport and store the
images in [`Artifacts/Screenshots`](Artifacts/Screenshots). `--stress-chat`
streams the 5,000-message fixture used by the scroll stress test. Both skip the
legacy host screen and shorten the mock chunk delay so a UI run does not wait
on simulated streaming.

## Architecture

```text
Host application (UIKit AppDelegate and SceneDelegate)
├── UIWindow and UIHostingController root
├── existing navigation
├── authenticated network session
├── mTLS, pinning, token and headers
├── secure authorization implementation
└── design tokens
          │ dependency injection
          ▼
TanyaAIModule.makeView
          │
          ▼
TanyaAIRootView
├── NavigationStack
│   ├── TanyaAIChatView
│   └── TanyaAIHistoryView
└── SwiftUI sheet<TanyaAIPINBottomSheetView>
          │
          ▼
View → ViewModel → UseCase → Repository → injected transport
```

`TanyaAIRouter` owns a small typed path and one optional authorization sheet.
Only a requested destination is rendered. There is no hidden `NavigationLink`
graph and no UIKit navigation object inside the production package.

The sandbox host keeps the classic UIKit lifecycle. `AppDelegate` supplies the
scene configuration, `SceneDelegate` builds the `UIWindow`, owns the
presentation gateway, and hosts the root SwiftUI screen in a
`UIHostingController`. The lifecycle boundary stays in the host, so an existing
`AppDelegate` and `SceneDelegate` application can adopt the feature without
moving to the SwiftUI `App` lifecycle. The package itself remains pure SwiftUI.

### Host actions and deeplinks

A bubble can ask the host to open one of its own screens. The response carries
the deeplink as one string, such as `ocbcid://mobile?type=transfer`:

```text
Action card or confirmation handoff
    → TanyaAIChatOutput.performAction
    → TanyaAIRouter
    → onAction handler in the host
    → host checks the scheme and its deeplink entry host
    → feature closes, then the host's existing deeplink handler takes over
```

The package never parses or opens the deeplink, never dismisses itself for an
action, and never navigates outside its own `NavigationStack`. The host checks
that the link is its own before opening it, so a response cannot point the app
at a web page or at another app. Schema
in [`docs/BUBBLE_SCHEMA.md`](docs/BUBBLE_SCHEMA.md), sequencing in
[`docs/INTEGRATION.md`](docs/INTEGRATION.md).

`MockTanyaAIActionFixture` in `TanyaAITestSupport` builds a stream carrying
deeplinks of your own, so a host can exercise the hand-off before the backend
sends one.

The sandbox demonstrates the full round trip: `--deeplink` streams an action
card and a confirmation with `handoff`, `SandboxDeeplink` accepts
`tanyaaisandbox://mobile?…`, and `SceneDelegate` receives the opened URL
through `scene(_:openURLContexts:)` exactly as an external caller would. One
button carries an `https` link the host rejects. `SandboxDeeplinkDispatcher`
stands in for the deeplink handler a real host application already owns.

### Reply formatting

Reply text may use inline emphasis - `**bold**`, `*italic*`, `` `code` `` -
and keeps its line breaks, so a labelled list stays inside one bubble. Block
syntax is deliberately not interpreted: headings, images, links, and tables
would hand layout control to the response. Contract in
[`docs/BUBBLE_SCHEMA.md`](docs/BUBBLE_SCHEMA.md).

### Package targets

| Target | Responsibility |
| --- | --- |
| `TanyaAIContracts` | Narrow interfaces implemented by the host |
| `TanyaAIDomain` | Models, repository protocol, and use cases |
| `TanyaAIDesignSystem` | Host-injected colors and fonts |
| `TanyaAIData` | SSE parser, DTO decoding, and repository implementation |
| `TanyaAIPresentation` | SwiftUI views and ViewModels |
| `TanyaAI` | Public composition root and typed SwiftUI navigation |
| `TanyaAITestSupport` | Sanitized mocks and deterministic fixtures |

Dependencies point inward toward contracts and domain rules. Domain code does
not import SwiftUI, UIKit, Alamofire, or a host application.

## Bubble design decision

The feature uses a **hybrid semantic model**:

- Separate semantic types when behavior, security, lifecycle, or fallback
  rules differ.
- Share layout primitives when multiple cards have the same visual structure.
- Use a typed variant (`kind` or `style`) when only content and iconography
  differ.

This avoids both extremes:

- one giant `summary` payload with many optional fields;
- one new renderer for every small visual variation.

### Current content types

| Content | Purpose | Shared variation |
| --- | --- | --- |
| `text` | Incoming and outgoing chat text | User/assistant styling |
| `information` | Safe generic text and key-value information | Allowlisted blocks |
| `chart` | Standalone data visualization | `bar`, `line`, `donut`, `progress` |
| `portfolio` | Portfolio total, performance, allocation, disclaimer | Reuses chart primitives |
| `financialList` | Bills, incoming funds, and holdings | `paidBills`, `incoming`, `holdings` |
| `approval` | A transaction proposal requiring explicit approval | Four typed `kind` values |
| `receipt` | Immutable successful-result summary | Shared key-value rows |
| `status` | Neutral, success, warning, or recoverable error state | Typed `level` |
| `unsupported` | Safe fallback for a newer unknown content type | Fallback text only |

### What is intentionally combined

The following confirmations are one `approval` type:

- currency conversion;
- time deposit;
- transfer;
- savings plan;
- generic fallback.

They share one state machine and one security action:

```text
awaitingApproval
    → authorizing
    → processing or completed
    → failed, expired, or cancelled
```

Paid bills, incoming funds, and holdings are one `financialList` type. They
share rows, totals, captions, and footnotes while `style` controls limited
semantic presentation.

### What remains separate

`approval`, `receipt`, `portfolio`, and `chart` must not become one generic
`summary` type:

- an approval can open secure authorization and has expiring identifiers;
- a receipt is immutable and cannot be approved;
- a portfolio owns performance and allocation semantics;
- a standalone chart owns allowlisted series and chart type rules.

Their visuals may reuse headers, rows, segmented bars, spacing, and typography
without merging their domain contracts.

### Decision rule for a new card

Use an existing type when all answers are yes:

1. Does it have the same user intent?
2. Does it have the same state machine?
3. Does it have the same security classification?
4. Can the existing required fields describe it without unrelated optionals?

Create a new semantic type if any answer is no. Extract a reusable view
primitive only after two real semantic cards need the same layout.

## Stream contract

The mock transport emits Server-Sent Event framing. A network chunk is not an
event boundary, so `TanyaAISSEParser` buffers arbitrary fragments and supports
both `\n\n` and `\r\n\r\n` separators.

### Response lifecycle

```text
event: response.started
data: {"messageIdentifier":"message-001"}

event: text.delta
data: {"messageIdentifier":"message-001","text":"Sample response"}

event: response.suggestions
data: {"suggestions":[]}

event: response.completed
data: {"messageIdentifier":"message-001"}
```

`response.suggestions` is response-driven. Suggestions may be returned after
every response, may change by context, or may be omitted. The ViewModel clears
stale suggestions while a new response is generating and replaces them only
when the backend emits a new suggestion event.

### Information JSON

Use information for non-transactional text and key-value facts.

```text
event: content.information
data: {
  "messageIdentifier": "information-001",
  "title": "Sample transfer limit",
  "text": "These values are sanitized demo data.",
  "items": [
    {"label": "Daily limit", "value": "IDR 50,000,000"},
    {"label": "Remaining", "value": "IDR 37,500,000"}
  ]
}
```

### Chart JSON

The backend chooses only an allowlisted chart type and supplies data. The app
owns colors, fonts, dimensions, accessibility labels, and animation.

```text
event: content.chart
data: {
  "messageIdentifier": "chart-001",
  "title": "Spending · month to date",
  "subtitle": "46 transactions",
  "totalValue": "IDR 24,790,000",
  "chartType": "bar",
  "series": [
    {
      "label": "Bills & utilities",
      "value": 45,
      "formattedValue": "IDR 11.26 M"
    }
  ],
  "footnote": "Information only."
}
```

Unknown chart types fall back to `bar`; arbitrary coordinates, fonts, colors,
HTML, JavaScript, and executable UI definitions are not accepted.

### Portfolio JSON

```text
event: content.portfolio
data: {
  "messageIdentifier": "portfolio-001",
  "title": "Portfolio summary",
  "totalValue": "IDR 2,451,000,000",
  "performanceText": "▲ 3.2% this year (indicative)",
  "allocations": [
    {
      "label": "Mutual funds",
      "value": 49,
      "formattedValue": "IDR 1.20 B"
    }
  ],
  "footnote": "Figures are indicative and for information only."
}
```

### Financial-list JSON

```text
event: content.financial-list
data: {
  "messageIdentifier": "list-001",
  "title": "Incoming · last 30 days",
  "style": "incoming",
  "rows": [
    {
      "title": "18 Jul · Salary",
      "subtitle": null,
      "value": "+IDR 62,000,000",
      "detail": null,
      "tone": "positive"
    }
  ],
  "totalLabel": "Total incoming",
  "totalValue": "IDR 62,000,000",
  "totalCaption": "1 transfer",
  "footnote": "Information only."
}
```

### Approval JSON

```text
event: content.approval
data: {
  "messageIdentifier": "approval-message-001",
  "approvalIdentifier": "approval-001",
  "transactionIdentifier": "transaction-001",
  "challengeIdentifier": "challenge-001",
  "kind": "transfer",
  "title": "Confirm your transfer",
  "summary": [
    {"label": "From", "value": "Sample Account ··1001"},
    {"label": "To", "value": "Sample Savings ··2002"},
    {"label": "Amount", "value": "IDR 5,000,000"}
  ],
  "notice": "Review the details before confirming.",
  "expiresAt": "2026-08-05T12:00:00Z"
}
```

The JSON never contains a PIN. Selecting Confirm sends a typed output to the
internal router, which lazily creates and presents the SwiftUI PIN sheet.

### Receipt JSON

```text
event: content.receipt
data: {
  "messageIdentifier": "receipt-001",
  "title": "Conversion complete",
  "detail": "USD 1,000 converted to IDR 16,250,000",
  "summary": [
    {"label": "New balance", "value": "IDR 41,300,000"},
    {"label": "Reference", "value": "DEMO-77120934"}
  ],
  "footnote": "A sanitized receipt was generated."
}
```

### Status JSON

```text
event: content.status
data: {
  "messageIdentifier": "status-001",
  "title": "Completed",
  "detail": "The sample request completed.",
  "level": "success"
}
```

### Suggestion JSON

```text
event: response.suggestions
data: {
  "suggestions": [
    {
      "identifier": "incoming",
      "title": "Incoming funds",
      "prompt": "Show incoming funds"
    }
  ]
}
```

### Forward-compatible fallback

An unknown `content.*` event is rendered safely when it provides the common
identifier and optional fallback text:

```text
event: content.future-card
data: {
  "messageIdentifier": "future-001",
  "fallbackText": "Update the app to view this card."
}
```

Unknown non-content events are ignored. Malformed known content ends the
stream with an error instead of rendering partially trusted data.

## Approval and PIN boundary

```text
Approval bubble
    → user taps Confirm
    → router sets typed SwiftUI sheet state
    → PIN ViewModel creates authorization request
    → injected host authorization service
    → result updates the original approval bubble
```

The package owns:

- numeric keypad UI;
- short-lived PIN presentation state;
- submit/cancel state;
- approval-card state updates.

The host owns:

- secure authorization and transaction execution;
- challenge generation and validation;
- authenticated networking, mTLS, and pinning;
- retry, lockout, and backend error policy.

The PIN must never enter chat messages, stream payloads, history, analytics,
logs, crash reports, clipboard, or local persistence. The package clears it on
submission, cancellation, and deallocation.

## Integration in another project

### Public API summary

| API | Use |
| --- | --- |
| `TanyaAIModule.makeView` | Creates one isolated SwiftUI feature graph |
| `TanyaAIConfiguration.init` | Supplies relative message path and optional initial prompt |
| `TanyaAIDependencies.init` | Injects transport, authorization, and theme |
| `TanyaAIStreamingTransport.stream` | Delivers raw response chunks and terminal result |
| `TanyaAIAuthorizationService.authorize` | Delegates secure approval to the host |
| `TanyaAICancellable.cancel` | Cancels an active stream or authorization task |
| `TanyaAITheme.init` | Maps host colors and fonts into the feature |

Only the factory and contracts are integration surface. Repositories,
ViewModels, decoders, and the internal router are implementation details.

### 1. Add the local package

In Xcode, use **File → Add Package Dependencies → Add Local** and select
`Packages/TanyaAI`. Link the `TanyaAI` product. The sandbox also links
`TanyaAITestSupport`, but a host application must not ship that product.

### 2. Implement streaming using the host network stack

```swift
import TanyaAI

final class HostStreamingAdapter: TanyaAIStreamingTransport {
    private let networkClient: HostStreamingNetworkClient

    init(networkClient: HostStreamingNetworkClient) {
        self.networkClient = networkClient
    }

    func stream(
        _ request: TanyaAIStreamRequest,
        onData: @escaping (Data) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) -> TanyaAICancellable {
        networkClient.stream(
            path: request.path,
            body: request.body,
            requestIdentifier: request.requestIdentifier,
            onData: onData,
            completion: completion
        )
    }
}
```

The adapter must reuse the host's existing authenticated session. Do not put
certificates, token refresh, absolute hosts, or mTLS setup inside Tanya AI.

### 3. Implement authorization using the host service

```swift
import TanyaAI

final class HostAuthorizationAdapter: TanyaAIAuthorizationService {
    private let authorizationClient: HostAuthorizationClient

    init(authorizationClient: HostAuthorizationClient) {
        self.authorizationClient = authorizationClient
    }

    func authorize(
        request: TanyaAIAuthorizationRequest,
        pin: String,
        completion: @escaping (
            Result<TanyaAIAuthorizationResult, Error>
        ) -> Void
    ) -> TanyaAICancellable {
        authorizationClient.authorize(
            request: request,
            pin: pin,
            completion: completion
        )
    }
}
```

Use a host-defined secure PIN value instead of `String` when the existing
authorization SDK exposes one and the contract can be migrated end to end.

### 4. Map host design tokens once

```swift
import TanyaAI

let theme = TanyaAITheme(
    colors: TanyaAIColors(
        background: HostPalette.background,
        surface: HostPalette.surface,
        primaryText: HostPalette.primaryText,
        secondaryText: HostPalette.secondaryText,
        accent: HostPalette.accent,
        userBubble: HostPalette.outgoingBubble,
        userBubbleText: HostPalette.onAccent,
        assistantBubble: HostPalette.incomingBubble,
        assistantBubbleText: HostPalette.primaryText,
        divider: HostPalette.divider,
        chartTrack: HostPalette.chartTrack,
        chartColors: HostPalette.chartSeries,
        success: HostPalette.success,
        warning: HostPalette.warning,
        error: HostPalette.error,
        overlay: HostPalette.overlay
    ),
    fonts: TanyaAIFonts(
        title: HostTypography.title,
        headline: HostTypography.headline,
        body: HostTypography.body,
        subheadline: HostTypography.subheadline,
        footnote: HostTypography.footnote,
        caption: HostTypography.caption,
        amount: HostTypography.amount,
        button: HostTypography.button
    )
)
```

All package screens use injected values. A production host should not use the
sandbox theme.

### 5. Build and present the feature

```swift
import TanyaAI

let dependencies = TanyaAIDependencies(
    streamingTransport: HostStreamingAdapter(
        networkClient: networkClient
    ),
    authorizationService: HostAuthorizationAdapter(
        authorizationClient: authorizationClient
    ),
    theme: theme
)

let configuration = TanyaAIConfiguration(
    messagePath: "/v1/chat/messages",
    initialPrompt: nil
)

struct HostScreen: View {
    @State private var showsTanyaAI = false

    var body: some View {
        Button("Open Tanya AI") {
            showsTanyaAI = true
        }
        .fullScreenCover(isPresented: $showsTanyaAI) {
            TanyaAIModule.makeView(
                configuration: configuration,
                dependencies: dependencies,
                onClose: {
                    showsTanyaAI = false
                }
            )
        }
    }
}
```

`TanyaAIModule` is a factory, not a singleton. Build a fresh feature graph for
each presentation. Keep one presentation gateway per window scene so duplicate
presentation can be rejected without introducing global mutable state.

### Entry from legacy SwiftUI navigation

Do not add Tanya AI as another destination in the legacy `NavigationLink`
graph. Put one `fullScreenCover` at a stable host/root boundary and let the
existing coordinator or ViewModel action toggle its binding:

```text
Legacy NavigationView screen
    → button action
    → scene-owned observable presentation gateway
    → fullScreenCover
    → independent TanyaAIRootView and NavigationStack
```

The sandbox UI test verifies that the legacy navigation position and local
screen state survive this presentation and dismissal.

## Adding a feature safely

Use this order for every new capability.

### 1. Write the behavior first

Define:

- user intent;
- success, error, cancellation, and expiry states;
- security classification;
- backend and client ownership;
- whether the result updates an existing message or creates a new one.

Do not begin by creating a new card view.

### 2. Choose the correct semantic model

Prefer an existing variant only when its intent and state machine match. If a
new required field would be unrelated to most variants, create a new semantic
payload instead of adding another optional property to a generic object.

### 3. Add the domain payload

Add a small value type under:

```text
Sources/TanyaAIDomain/Models
```

Domain models contain meaning, not layout coordinates or networking details.

### 4. Add DTO and mapper support

Add the backend-only shape under `TanyaAIData/DTO`, then decode it to the
domain model in `TanyaAIStreamEventDecoder`. Unknown enum values must use a
documented safe fallback or fail decoding. Never pass an unvalidated action
string directly into UI behavior.

### 5. Add presentation

Add a focused renderer under `TanyaAIPresentation/Components` and one case in
`TanyaAIMessageRowView`. Keep the view declarative. It may emit a typed user
intent but may not call repositories, services, or routers.

### 6. Add business logic at the correct layer

| Concern | Owner |
| --- | --- |
| Layout and user gesture | View |
| UI state and typed output | ViewModel |
| Feature orchestration and policy | UseCase |
| Domain-facing data operations | Repository protocol |
| JSON, SSE, and remote mapping | Data layer |
| mTLS, token, pinning, secure execution | Host adapter |
| Internal screen transitions | UIKit coordinator |

### 7. Add tests before merging

Every new bubble or feature requires:

- decoder tests for valid, malformed, and unknown values;
- ViewModel tests for success, error, cancellation, and repeated events;
- navigation tests for every new route or secure overlay;
- one deterministic fixture;
- one UI assertion and screenshot for each materially different layout;
- lifecycle coverage for every new long-lived callback or task;
- a performance rerun when the row is complex or frequently updated.

### 8. Update the schema and README

Document the event name, required fields, optional fields, fallback behavior,
security class, and minimum supported app version.

## Test strategy

The project does not claim that a single “100% coverage” number proves
correctness. Compiler-generated SwiftUI paths and simple value initializers can
inflate or reduce line coverage without exercising behavior. The required gate
is:

- all critical domain, data, state-machine, and navigation branches tested;
- every semantic bubble decoded by a unit test;
- every materially different bubble rendered in the showcase UI test;
- every confirmation kind proven to route to PIN;
- valid and invalid PIN paths tested;
- lifecycle and cancellation tests passing;
- coverage measured and reviewed for unexplained zero-coverage business code.

### Latest verified baseline

Measured on 5 August 2026 with an iPhone 17 Pro simulator running iOS 26.5:

| Evidence | Result |
| --- | --- |
| Package tests | 49 passed, 0 failed |
| UI and integration tests | 5 passed, 0 failed |
| Data source unit coverage | 96.14% |
| Domain source unit coverage | 100.00% |
| Presentation source unit coverage | 42.44% plus UI showcase |
| Feature composition coverage during UI run | 89.32% |
| Sandbox app coverage during UI run | 98.66% |
| Lifecycle release checks | 5 passed, including router/PIN and 5,000-row graphs |
| 5,000-message ingestion | 0.11–0.21 seconds; 38.38–38.41 MB process peak |
| 2,000-row calibrated scroll | 53.88 FPS against 53.28 FPS host baseline |
| 5,000-row UI stress | Latest row reached; 16 rapid swipes passed |
| SSE parser sample | 1,000 events; current gate passed |

Presentation unit-test line coverage is lower because SwiftUI body builders and
simple view declarations are executable lines. Rendering coverage is therefore
validated separately by the UI showcase, which scrolls each current semantic
layout into the viewport and stores a screenshot. Coverage values exclude test
files when reported as source coverage.

### Unit, lifecycle, and performance tests

```sh
cd Packages/TanyaAI

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/tanya-ai-package-coverage.xcresult
```

### UI and integration tests

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -project TanyaAISandbox.xcodeproj \
  -scheme TanyaAISandbox \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/tanya-ai-ui-coverage.xcresult
```

### Read the coverage report

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcrun xccov view \
  --report \
  --only-targets \
  /tmp/tanya-ai-package-coverage.xcresult
```

Review source coverage by responsibility. Do not include test files and mocks
when reporting production coverage. A changed business method with zero
executions is a merge blocker even when the aggregate percentage stays high.

## Memory-leak verification

Automated lifecycle tests use weak references to verify release of:

- chat ViewModel with an active stream;
- PIN ViewModel with an active authorization request;
- the complete SwiftUI root, router, dependency graph, and hosted test graph;
- the router, ViewModel, first row, and last row after 5,000 messages.

They also verify that active cancellables receive `cancel()` during teardown.

Run only lifecycle tests:

```sh
cd Packages/TanyaAI

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:TanyaAIPerformanceTests/TanyaAILifecycleTests
```

### Required Instruments check before release

1. Build Release on the oldest supported physical iPhone.
2. Open Instruments with **Leaks** and **Allocations**.
3. Mark a baseline after launch.
4. Repeat open → stream → confirm → PIN → close at least 25 times.
5. Trigger a stream cancellation and an authorization failure.
6. Use **Mark Generation** after each group of five cycles.
7. Confirm no leaked objects and no continuously growing retained generation.
8. Inspect retain paths for router, root view state, ViewModel, repository,
   stream context, and callback closures.

A weak-reference test passing means no retained graph was found in that tested
lifecycle. It is evidence, not a universal proof that every future integration
has no leak.

## Frame-rate and performance verification

The chat uses:

- `ScrollViewReader` and a separator-free `LazyVStack`;
- stable message identifiers;
- one observable object per message row;
- constant-time message lookup through an identifier index;
- a 40 ms text-delta batching window;
- lazy destination creation;
- cancellation of pending requests and buffer work.

The current simulator baseline is documented in
[`docs/PERFORMANCE.md`](docs/PERFORMANCE.md). The automated scroll benchmark
uses 2,000 rows and compares active scrolling with an idle `CADisplayLink`
baseline from the same process. A separate fixture loads, scrolls, and releases
5,000 messages.

### Measure FPS locally

```sh
cd Packages/TanyaAI

DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:TanyaAIPerformanceTests/TanyaAIFrameRateTests
```

Read `TANYA_AI_BASELINE_FPS` and `TANYA_AI_SCROLL_FPS` from the test output.
The automated gate requires scroll cadence to retain at least 97% of the host
baseline. Absolute 60 FPS must be measured on a 60 Hz-capable physical device.

### Required device gate

Use a Release build and Instruments **Core Animation** or the Xcode Organizer
hitch metrics on the oldest supported physical device. Test:

- a 2,000-message conversation;
- the 5,000-message stress fixture;
- the product maximum history length;
- fast scrolling while streaming;
- charts and all financial cards;
- opening and closing PIN repeatedly;
- Low Power Mode and realistic network delay.

Target the display refresh rate without sustained drops. A simulator result
cannot guarantee 60 FPS on every physical device, so device profiling remains
a release requirement.

## Forbidden patterns

The following are not allowed in this package:

- `NavigationView` or `NavigationLink` for internal Tanya AI navigation;
- UIKit, `UIViewRepresentable`, view controllers, or hosting controllers in
  production package sources;
- destination lists embedded in every screen;
- constructing or configuring ViewModels, use cases, or services in `body`;
- a singleton router, singleton feature graph, or hidden global presenter;
- `AnyView` as a general dynamic bubble renderer;
- arbitrary backend-driven layout, HTML, JavaScript, coordinates, or colors;
- arbitrary action names or URLs executed directly from a response;
- raw PIN in messages, prompts, logs, analytics, storage, or clipboard;
- certificates, tokens, secrets, absolute production hosts, or customer data;
- a second mTLS or authentication stack inside the package;
- strong callback cycles; long-lived callbacks must capture owners weakly;
- one full conversation-array replacement for every streamed token;
- unstable message identifiers or duplicate insertion for state updates;
- force unwraps and force tries in production paths;
- swallowing malformed known content as if it were valid;
- files longer than 250 lines or large multi-purpose methods;
- variable names shorter than three characters or longer than forty characters;
- modifying UI state from a background queue;
- claiming “no leaks” or “60 FPS guaranteed” without device evidence.

## Best practices

- Create one feature graph per presentation through `TanyaAIModule`.
- Keep one scene-owned presentation gateway in the host.
- Keep `body` pure and make side effects explicit in ViewModels/use cases.
- Prefer immutable domain payloads and request-scoped identifiers.
- Use typed enums for routes, content, actions, state, and failure policy.
- Reuse the host network session and security implementation through adapters.
- Batch streamed deltas before publishing UI changes.
- Update an existing bubble by stable identifier when its state changes.
- Keep suggestions response-driven and clear stale suggestions during requests.
- Provide safe fallback text for forward-compatible content.
- Inject dynamic type-aware fonts and semantic colors from the host.
- Maintain 44-point minimum interactive targets and useful accessibility labels.
- Test cancellation, timeout, malformed stream, duplicate event, and retry paths.
- Profile the oldest physical device before release.
- Keep mocks deterministic, sanitized, and impossible to confuse with production.

## Screenshots

The UI suite renders more than ten messages, every current financial family,
all status levels, the unsupported fallback, dynamic suggestions, and the PIN
sheet. Kept screenshots are under `Artifacts/Screenshots`.

Examples:

- [`confirmation-transfer.png`](Artifacts/Screenshots/confirmation-transfer.png)
- [`portfolio-summary.png`](Artifacts/Screenshots/portfolio-summary.png)
- [`spending-chart.png`](Artifacts/Screenshots/spending-chart.png)
- [`paid-bills-list.png`](Artifacts/Screenshots/paid-bills-list.png)
- [`incoming-funds-list.png`](Artifacts/Screenshots/incoming-funds-list.png)
- [`pin-bottom-sheet.png`](Artifacts/Screenshots/pin-bottom-sheet.png)
- [`stress-5000-messages.png`](Artifacts/Screenshots/stress-5000-messages.png)
- [`stress-after-rapid-scroll.png`](Artifacts/Screenshots/stress-after-rapid-scroll.png)

## Additional documentation

- [`docs/BUBBLE_SCHEMA.md`](docs/BUBBLE_SCHEMA.md)
- [`docs/INTEGRATION.md`](docs/INTEGRATION.md)
- [`docs/PERFORMANCE.md`](docs/PERFORMANCE.md)
- [`Examples/NavigationViewHost`](Examples/NavigationViewHost) — copy-ready
  adapters and wiring for a `NavigationView` host that keeps `AppDelegate` and
  `SceneDelegate`
