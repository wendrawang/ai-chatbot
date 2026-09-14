# Typed bubble and suggestion schema

## How a bubble reaches the screen

Each bubble is **one message on the vendor channel**. The event name goes in
the message's `custom_type`, and the payload goes in `data` as a **JSON
string** - not an object.

```json
{
  "message_type": "MESG",
  "user_id": "<bot>",
  "message": "plain-text body - see below for when it is read",
  "custom_type": "content.actions",
  "data": "{\"messageIdentifier\":\"act-1\", ...}"
}
```

Three rules follow from that shape:

- **One message, one bubble.** A reply of text *then* a confirmation is two
  messages sent in order. There is no array-of-bubbles format.
- **`messageIdentifier` is required on every payload**, and should be unique
  per bubble.
- **A message with no `custom_type` is a text bubble**, taking `message` as
  its content.

`message` is *not* the fallback for a card this app is too old to draw. That
fallback is `fallbackText`, inside `data`. On a typed card `message` is never
rendered - neither live nor when history is read back, both of which take the
card from `data`. It still earns its place: Sendbird uses it for push previews
and its dashboard, and it is what any other client shows. Write it as if
nobody had the app.

A message whose `custom_type` does not begin with `content.` is treated as
plain text.

## Field reference

**This table is the contract.** The JSON shown later in this document, and the
payloads in `send-bubble.sh`, are examples of it - if they ever disagree, this
table and the DTOs it mirrors are what the package actually decodes.

Required unless marked optional. `expiresAt` is ISO 8601.

| Event | Fields |
| --- | --- |
| `content.image` | `imageURL`, `caption`, `aspectRatio?` (number), `accessibilityText?` |
| `content.choices` | `title?`, `choices[]` of `{identifier, title, prompt?}`, `allowsMultipleSelection?`, `submitTitle?` |
| `content.information` | `title?`, `text`, `items[]` of `{label, value}` |
| `content.status` | `title`, `detail`, `level` |
| `content.actions` | `actions[]` of `{title, style?, action:{identifier, deeplink}}` |
| `content.approval` | `approvalIdentifier`, `transactionIdentifier`, `challengeIdentifier`, `kind?`, `title`, `summary[]` of `{label, value}`, `notice?`, `expiresAt`, `handoff?:{identifier, deeplink}` |
| `content.receipt` | `title`, `detail`, `summary[]` of `{label, value}`, `footnote?` |
| `content.chart` | `title`, `subtitle?`, `totalValue?`, `chartType`, `series[]` of `{label, value (number), formattedValue}`, `footnote?` |
| `content.portfolio` | `title`, `totalValue`, `performanceText`, `allocations[]` of `{label, value (number), formattedValue}`, `footnote?` |
| `content.financial-list` | `title`, `style`, `rows[]` of `{title, subtitle?, value, detail?, tone?}`, `totalLabel?`, `totalValue?`, `totalCaption?`, `footnote?` |

Allowlisted values - anything else falls back to the first entry:

| Field | Accepts |
| --- | --- |
| `status.level` | `neutral`, `success`, `warning`, `error` |
| `chart.chartType` | `bar`, `line`, `donut`, `progress` |
| `financial-list.style` | `paidBills`, `incoming`, `holdings` |
| `financial-list.rows[].tone` | `neutral`, `positive` |
| `actions[].style` | `primary`, `secondary` |

### Any `content.*` this app does not know

Decoded as the unsupported bubble, reading one optional field from `data`:

| Field | Purpose |
| --- | --- |
| `fallbackText` | The sentence shown in the placeholder. Omitted, the app says "requires a newer app version". |

This is what the `content.` prefix buys. A name outside the prefix that the
app does not know is dropped without trace; inside it, the turn still leaves
something on screen.

### `content.choices`

A question answered by picking and confirming. What separates it from
`response.suggestions` is the submit button, not the number of choices: a
single-select question that still waits for confirmation belongs here, and a
multi-select one that sent on every tap would be unusable.

| Field | Purpose |
| --- | --- |
| `choices[].prompt` | What is sent when this choice is part of the answer. Omitted, the chip's own `title` is sent. |
| `allowsMultipleSelection` | Default true. False makes each tap replace the selection. |
| `submitTitle` | Default "Submit". |

The answer is the selected prompts joined with ", ", in the order the choices
were offered rather than the order they were tapped. A submitted card stays on
screen and stops accepting input: the conversation is the record of what was
asked as well as what was answered.

### `content.actions`

Links only - no heading. Whatever explains the hand-off is sent as an ordinary
text message before it, the way the design shows it. `title` and `detail` are
no longer read; sending them is harmless but draws nothing.

### `content.image`

`aspectRatio` is width divided by height. Send it. It reserves the row's
height before the picture is downloaded, and without it the conversation grows
under the customer's eyes when the image lands - the app falls back to 16:9,
which is a guess that will usually be wrong by a little.

An `imageURL` the app cannot parse is not an error: the bubble shows the
caption alone. The sentence is the message, and losing the whole bubble over a
broken link would lose more than the picture.
| `approval.kind` | `transfer`, `currencyConversion`, `timeDeposit`, `savingsPlan`, `generic` |

Runnable examples of every one of these are in
[`Examples/VendorChatSDK/Sendbird/send-bubble.sh`](../Examples/VendorChatSDK/Sendbird/send-bubble.sh).

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
UIKit coordinator lazily presents the numeric PIN bottom sheet. PIN values are
short-lived presentation state and never become chat content or stream data.

## Host actions

An action asks the host to open one of its own screens. The response carries
the deeplink as one string, in whatever shape the host's existing deeplink
handler already accepts:

`custom_type: content.actions`

```json
{
  "messageIdentifier": "act-1",
  "title": "Lanjutkan di aplikasi",
  "detail": "Membuka layar yang sudah ada",
  "actions": [
    {
      "title": "Buka transfer",
      "style": "primary",
      "action": {
        "identifier": "open-transfer",
        "deeplink": "ocbcid://mobile?type=transfer"
      }
    }
  ]
}
```

`style` accepts `primary` and `secondary`; anything else falls back to
`primary`. An empty `actions` array renders the unsupported fallback instead
of an empty card. `identifier` is for accessibility identifiers and analytics,
never for routing.

A confirmation can hand off the same way. When `handoff` is present the
`Confirm` button stops opening the in-feature PIN sheet and reports the action
to the host, so an existing authorization flow can take over:

`custom_type: content.approval`

```json
{
  "messageIdentifier": "apv-1",
  "approvalIdentifier": "approval-001",
  "transactionIdentifier": "trx-001",
  "challengeIdentifier": "chl-001",
  "kind": "transfer",
  "title": "Konfirmasi transfer Anda",
  "summary": [
    { "label": "Ke", "value": "Sample Beneficiary" },
    { "label": "Jumlah", "value": "IDR 1.250.000" }
  ],
  "notice": "Otorisasi dilakukan di flow existing.",
  "expiresAt": "2099-01-01T00:00:00Z",
  "handoff": {
    "identifier": "handoff-transfer",
    "deeplink": "ocbcid://mobile?type=transfer&amount=1250000"
  }
}
```

The package forwards the deeplink and does nothing else: it does not parse it,
open it, dismiss itself, or navigate. Because the string arrives from the
stream, the host must check it before opening: the scheme has to be the app's
own, and the host has to be the app's deeplink entry point. Anything else is
dropped. Resolving the link to a screen stays with the host's existing
deeplink handler.

## Text formatting

Reply text may carry inline styling, so a labelled list reads as one answer
instead of several bubbles. The wire format is a closed set of bracket tags:

| Tag | Renders |
| --- | --- |
| `[bold]wen[/bold]` | Bold |
| `[italic]wen[/italic]` | Italic |
| `[underline]wen[/underline]` | Underlined |
| `[strike]wen[/strike]` | Struck through |
| `[color]wen\|25C36B[/color]` | Text in `#25C36B` |

Markdown is deliberately not used. Asterisks are ordinary characters in
banking copy - masked cards, footnote markers - and a closed tag set means a
response can reach exactly these three styles and nothing else: no links, no
images, no headings.

Behaviour the client guarantees:

- **An unknown tag is dropped and its text kept**, so a backend can ship a new
  tag before the app supports it.
- **An unclosed tag styles the remainder**, since text arrives in chunks.
- **A half-arrived tag is hidden** rather than flashing raw markup.
- **A mismatched closing tag keeps the content** and forgets the styling.
- **Anything else is literal.** `biaya [1] gratis` shows its brackets.

`[color]` carries its value inside the element, after the last `|`, and only
six-digit RRGGBB is accepted. Note that this hands colour choice to the
response: a value with poor contrast against the bubble is the backend's
mistake to make. If that matters, restrict the palette server-side.

## Dynamic suggestions

Suggestions use the event name `response.suggestions`. `title` is optional -
it is the question the prompts answer, drawn above them in the same bubble,
and a reply offering follow-ups that need no heading simply omits it. One tap
sends; for a question that should wait for confirmation use
`content.choices`.

```json
{
  "title": "Kategori apa yang diinginkan",
  "suggestions": [
    {
      "identifier": "incoming",
      "title": "Incoming funds",
      "prompt": "Show incoming funds"
    }
  ]
}
```

**Not currently reachable over a vendor channel.** The Sendbird adapter
forwards only names beginning with `content.`, so a suggestion sent this way
arrives as plain text. The package decodes the event; widening that filter in
the adapter is what would connect it.

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
