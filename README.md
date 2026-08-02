# Tanya AI Sandbox

A sanitized iOS 13 reference implementation for a modular conversational app.
It contains no production endpoints, certificates, secrets, proprietary source
code, internal identifiers, or customer data.

## Architecture

- UIKit owns internal navigation through `UINavigationController`.
- SwiftUI screens are hosted with `UIHostingController`.
- Presentation follows MVVM.
- Domain logic is implemented through use cases and repository protocols.
- Streaming and approval services are injected through public contracts.
- Every color and font is injected by the host through `TanyaAITheme`.
- Chat rows use a reusable, separator-free table for large conversations.
- The sandbox app uses deterministic mocks only.

The local package is split into these targets:

1. `TanyaAIContracts`
2. `TanyaAIDomain`
3. `TanyaAIDesignSystem`
4. `TanyaAIData`
5. `TanyaAIPresentation`
6. `TanyaAI`
7. `TanyaAITestSupport`

## Run

Open `TanyaAISandbox.xcodeproj`, select an iPhone simulator, and run the
`TanyaAISandbox` scheme. The demo PIN is `123456` and is valid only in the
mock authorization service.

The initial screen simulates the existing application's legacy
`NavigationView` and `NavigationLink` hierarchy. Its nested detail screen opens
Tanya AI through a UIKit presentation gateway, outside the legacy navigation
stack. Closing Tanya AI returns to the same legacy destination and preserves
its local state.

Tanya AI provides four offline demo journeys:

- sample portfolio with a dedicated financial card;
- spending insight with a reusable chart primitive;
- transfer-limit information with allowlisted information blocks;
- sample transfer approval with an iOS 13-compatible PIN bottom sheet.

Streamed text deltas are coalesced into short UI batches to avoid publishing a
full row update for every token. Pending text is flushed when a response ends
or is cancelled, preserving partial responses.

The automated showcase renders more than ten bubbles and captures the top,
middle, bottom, and PIN states. Generated images are stored in
`Artifacts/Screenshots`.

See `docs/PERFORMANCE.md` for the latest simulator measurements and the
required real-device production gate.

## Verify

```sh
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
  ./Scripts/verify.sh
```

## Production integration

The host application must inject implementations of:

- `TanyaAIStreamingTransport`
- `TanyaAIAuthorizationService`
- `TanyaAITheme`

Those adapters should reuse the host application's existing authenticated
network session, mTLS configuration, certificate pinning, transaction service,
and secure authorization implementation. See `docs/INTEGRATION.md`.
