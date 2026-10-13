# Session stream and partial integration migration

The chat now models an open channel. Sending a prompt submits it to the SDK; a bot reply is an independent incoming message. There is no Stop button or assumption that a reply completes the last prompt. A new prompt may be submitted while the bot/agent is typing. The backend decides whether it changes context. Late replies remain visible because the backend supplies no correlation metadata.

## Package and adapter update

Update DesignKit and TanyaAI together. Copy the complete Tencent example root Swift files into the host target (exclude Tests). Keep `.tanyaAIHost(appState.tanyaAIHost)` and `host.present()`; SDK init/login/logout and group provisioning still belong to AppState/backend.

`TanyaAIChatSession.send(text:context:requestIdentifier:)` now returns the assigned SDK message ID, or nil if the SDK assigns it later. The method is discardable. Emit `.sendSucceeded(requestIdentifier:messageIdentifier:)` or `.sendFailed(requestIdentifier:error:)` for that local submission. `.failed` / `.disconnected` describe the channel; `.historyFailed` describes history loading. Never use an incoming bot message as a send acknowledgement. ThreeDolphins' supplied API only confirms local submission and exposes no delivery receipt; Tencent/Sendbird use their send callbacks. No status here means the bot read the message.

History precedes `.connected`; an adapter without history can report `.connected` directly. History failure can be followed by `.connected`, allowing the user to continue with a localized warning. On retry, guard SDK callbacks using a connection generation. Disconnect unregisters this screen's listeners; it does not log out the shared SDK or delete the group.

## Start with DesignKit and the composer

The parent owns the draft and outer margin. DesignKit owns only the input's inner padding and appearance. Do not create a composer ViewModel.

```swift
import DesignKit
import SwiftUI

struct EmptyChatScreen: View {
    @State private var draft = ""
    let placeholder: String
    let sendLabel: String
    let onSend: (String) -> Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            MessageComposer(
                text: $draft,
                placeholder: placeholder,
                sendLabel: sendLabel,
                onSend: { if onSend(draft) { draft = "" } }
            )
            .padding(.horizontal, FigmaSize.spacing16.sizeInArtwork)
            .padding(.vertical, FigmaSize.spacing8.sizeInArtwork)
        }
    }
}
```

Apply `.theme(selectedTheme)` at the parent. `.sizeInArtwork` reads the 375×812 reference internally; there is no artwork environment object or root modifier. The composer keeps a white surface, radius 8, visual send control 24, touch target at least 44, and grows through four lines before scrolling.

The old `stopLabel`, `isGenerating`, and `onStop` arguments are removed. The host supplies localized placeholder/action labels. It may keep the field editable while `isEnabled` disables submission.

## Add TanyaAI's screen and channel

`ChatUseCase` and `HistoryViewModel` are removed. The screen model receives the SDK-neutral repository directly; the SDK remains outside both packages.

```swift
import SwiftUI
import TanyaAIContracts
import TanyaAIData
import TanyaAIPresentation

@MainActor
final class ChatOwner: ObservableObject {
    let model: TanyaAIChatViewModel

    init(session: TanyaAIChatSession) {
        model = TanyaAIChatViewModel(
            repository: TanyaAISessionRepository(session: session)
        )
    }
}
```

Also import `TanyaAIContracts` for `TanyaAIChatSession`. Own `ChatOwner` once with `@StateObject`, pass `owner.model` to `ChatScreen(viewModel:)`, and apply the theme at the screen boundary. Do not create the owner, repository, or adapter inside `body`. Every presentation receives a fresh adapter.

`sendMessage(_:) -> Bool` reports whether the channel accepted the submission locally. False preserves the editor draft and selection. The editor draft is now local to `ComposerSection`; it is not `viewModel.inputText`. For custom editors, call `sendMessage(draft)` and clear your binding only when true. `draftRequest` carries an identified prefill from actions such as editing an approval.

Initial history blocks submission until the channel is ready. A configured `startInitialPrompt(_:)` is deferred until readiness and runs once; the default host configuration has no initial prompt or greeting. History retry uses the SDK snapshot, reuses known rows by SDK ID, preserves pending/failed outbox rows, and does not reactivate consumed options or settled approvals. Only the latest answer offers active radio options; older options remain visible as read-only history.

Outgoing rows have pending/sent/failed status. Retry reuses the failed row with a new local submission ID. Local IDs never imply backend reply correlation. If delivery is uncertain, retry may produce another server message; backend idempotency is outside the current contract.

History screens use `ConversationHistoryScreen(items:)`. These are host-provided summaries; cross-group history selection is not implemented. The Figma UI adds an optional `makeNewSession` factory and welcome configuration. The factory must supply a fresh empty conversation; server provisioning remains the host/backend's responsibility. See [FIGMA_CHAT_UI.md](FIGMA_CHAT_UI.md).

For consolidating the existing design system first, follow [DESIGNKIT_PHASED_MIGRATION.md](DESIGNKIT_PHASED_MIGRATION.md). Its first checkpoint covers Legacy compatibility, one token/font source, and one sizing implementation before adopting chat components.

## Validation and team conventions

See [COMPONENT_STYLE.md](COMPONENT_STYLE.md) for naming/state/layout rules and [SESSION_VALIDATION.md](SESSION_VALIDATION.md) for tested behavior and device gates. UITableView is retained; cells use native UIHostingConfiguration when available and a contained hosting controller on iOS 15.
