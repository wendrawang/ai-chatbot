# Typed bubble and suggestion schema

## Rendering boundary

The backend selects a semantic message type and sends its data. The iOS
package owns layout, colors, typography, accessibility, interaction rules, and
fallback behavior. It does not accept arbitrary SwiftUI, HTML, coordinates,
fonts, or executable actions from a response.

Current semantic content types are:

- text;
- information;
- approval;
- receipt;
- portfolio;
- chart;
- financial list;
- status;
- host actions;
- unsupported fallback.

The schema is hybrid rather than one generic `summary` payload. Approvals and
financial lists use typed variants because their behavior remains the same.
Approval, receipt, portfolio, and chart remain separate because their state,
security, and fallback rules differ. Their renderers still share visual
primitives.

Confirmation variants share one typed approval renderer:

- currency conversion;
- time deposit;
- transfer;
- savings plan;
- generic fallback.

A confirmation that reached `completed`, `failed`, `expired`, or `cancelled`
is closed and never changes again. Two consequences for the response contract:

- a later `content.approval` reusing the same `messageIdentifier` renders a
  **new** bubble rather than reopening the closed one, so a confirmation the
  customer rejected stays rejected on screen;
- a state update arriving late - an authorization callback for a sheet the
  customer already dismissed - is ignored.

Reuse of a `messageIdentifier` is still worth avoiding: send a fresh one per
confirmation, and the intent is unambiguous.

Every pending confirmation exposes the same `Confirm` intent. The internal
router lazily presents the numeric PIN bottom sheet. PIN values are
short-lived presentation state and never become chat content or stream data.

## Host actions

An action asks the host to open one of its own screens. The response carries
the deeplink as one string, in whatever shape the host's existing deeplink
handler already accepts:

```json
event: content.actions
data: {
  "messageIdentifier": "actions-1",
  "title": "Continue in the app",
  "detail": "These open the existing screens.",
  "actions": [
    {
      "title": "Open transfer form",
      "style": "primary",
      "action": {
        "identifier": "open-transfer",
        "deeplink": "ocbcid://mobile?type=transfer&accountNumber=0000111122"
      }
    }
  ]
}
```

`style` accepts `primary` and `secondary`; anything else falls back to
`primary`. An empty `actions` array renders the unsupported fallback instead
of an empty card.

A confirmation can hand off the same way. When `handoff` is present the
`Confirm` button stops opening the in-feature PIN sheet and reports the action
to the host, so an existing authorization flow can take over:

```json
event: content.approval
data: {
  "messageIdentifier": "approval-1",
  "approvalIdentifier": "approval-1",
  "transactionIdentifier": "transaction-1",
  "challengeIdentifier": "challenge-1",
  "kind": "transfer",
  "title": "Confirm your transfer",
  "summary": [{ "label": "To", "value": "Sample Beneficiary" }],
  "expiresAt": "2099-01-01T00:00:00Z",
  "handoff": {
    "identifier": "handoff-transfer",
    "deeplink": "ocbcid://mobile?type=transfer&amount=1250000"
  }
}
```

`identifier` is for accessibility identifiers and analytics, never for
routing. The package forwards the deeplink and does nothing else: it does not
parse it, open it, dismiss itself, or navigate.

Because the string arrives from the stream, the host must check it before
opening: the scheme has to be the app's own, and the host has to be the app's
deeplink entry point. Anything else is dropped. Without that check a response
could point at another app or at a web page. Resolving the link to a screen
stays with the host's existing deeplink handler.

## Text formatting

Reply text may carry inline styling, so a labelled list reads as one answer
instead of several bubbles. The wire format is a closed set of bracket tags:

| Tag | Renders |
| --- | --- |
| `[bold]wen[/bold]` | Bold |
| `[strike]wen[/strike]` | Struck through |
| `[color]wen\|25C36B[/color]` | Text in `#25C36B` |

```json
event: text.delta
data: {
  "messageIdentifier": "text-1",
  "text": "[bold]1. Tentukan tujuan[/bold]: pilih jangka waktu."
}
```

Markdown is deliberately not used. Asterisks are ordinary characters in
banking copy - masked cards, footnote markers - and a closed tag set means a
response can reach exactly these three styles and nothing else: no links, no
images, no headings.

Behaviour the client guarantees:

- **An unknown tag is dropped and its text kept.** A backend that ships a new
  tag before the app supports it degrades to plain text rather than showing
  markup to the customer.
- **An unclosed tag styles the remainder.** Text arrives in chunks, so
  `[bold]wen` is already bold while the rest is on its way.
- **A half-arrived tag is hidden.** `wen [bo` renders as `wen ` instead of
  flashing raw markup, and completes on the next chunk.
- **A mismatched closing tag keeps the content** and forgets the styling.
- **Anything else is literal.** `biaya [1] gratis` shows its brackets.

`[color]` carries its value inside the element, after the last `|`, and only
six-digit RRGGBB is accepted; anything else leaves the text unstyled. Note
that this hands colour choice to the response: a value with poor contrast
against the bubble is the backend's mistake to make. If that matters, restrict
the palette server-side, or map names to theme tokens instead of sending hex.

## Dynamic suggestions

Suggestions are delivered as a separate stream event:

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

The ViewModel replaces the current chips with the latest event. The backend
may return suggestions after every response, return a different set for each
context, or omit them. Suggestions are cleared while generation is active so
stale actions cannot be selected against a new response.

## Reusable financial primitives

Charts use an allowlisted chart type plus typed series data. The host theme
owns the chart palette. Financial lists use a typed style for paid bills,
incoming funds, or holdings while sharing row, total, caption, and footnote
models.

Dedicated financial contexts remain semantic even when they reuse primitives:

- portfolio owns its total, performance, allocation series, and disclaimer;
- spending owns its total, comparison text, series, and disclaimer;
- receipts own success state and immutable summary rows;
- confirmations own kind, summary rows, notice, identifiers, and state.

Unknown event types map to an unsupported fallback instead of crashing or
rendering an untrusted layout.
