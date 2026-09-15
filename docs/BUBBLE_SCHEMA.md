# Bubble schema

What the bot sends, and which bubble it becomes.

Read the envelope once, then the one section for the bubble you are sending.
Every section shows the smallest payload that works, then what each optional
field adds.

## The envelope

A bubble is one chat message. The payload rides in a field the vendor sets
aside for application data; on Sendbird that is `custom_type` + `data`:

```json
{
  "message_type": "MESG",
  "user_id": "bot-user-id",
  "custom_type": "content.status",
  "message": "Transfer selesai",
  "data": "{\"messageIdentifier\":\"st-1\",\"title\":\"Selesai\"}"
}
```

| Field | Purpose |
| --- | --- |
| `custom_type` | The event name. This is what picks the bubble. |
| `data` | The payload, **as a JSON string**, not an object. |
| `message` | Plain text. Never drawn on a typed bubble - see below. |

Three rules that hold everywhere:

- **No `custom_type` means a text bubble**, taking `message` as its content.
- **`messageIdentifier` is the bubble's identity**, not the message's. Reuse
  one and the second bubble overwrites the first.
- **`message` is not a fallback.** On a typed bubble it is never drawn, live
  or in history. It is what the vendor dashboard, push previews and other
  clients show, so write it as if nobody had the app.

## Why every name starts with `content.`

The prefix does three jobs, and dropping it breaks all three.

**It tells the adapter what to do.** Anything under `content.` is passed
through untouched as a payload; anything else is read as plain text. Adding an
eleventh bubble needs no app release for the adapter to route it.

**It turns "app too old" into something visible.** An unknown name *inside*
the prefix becomes the update-required bubble. An unknown name *outside* it is
dropped without trace. In a banking conversation a silent gap is worse than a
placeholder - the customer cannot tell a reply went missing.

**It separates the two families.** `content.*` fills a reply;
`response.started`, `text.delta`, `response.completed`, `response.suggestions`
and `heartbeat` frame one.

---

# Bubbles

## Text

No `custom_type`. The content is `message`.

```json
{ "message": "Saldo Anda IDR 12.500.000." }
```

Inline styling uses a closed tag set, never Markdown - asterisks are ordinary
characters in banking copy:

| Tag | Result |
| --- | --- |
| `[bold]wen[/bold]` | Bold |
| `[italic]wen[/italic]` | Italic |
| `[underline]wen[/underline]` | Underlined |
| `[strike]wen[/strike]` | Struck through |
| `[color]wen\|25C36B[/color]` | Text in `#25C36B` |

Tags nest, so `[bold][underline]x[/underline][/bold]` is both. A tag this app
does not know is dropped and its text kept.

## Image

`custom_type: content.image`

**Minimal**

```json
{
  "messageIdentifier": "img-1",
  "imageURL": "https://cdn.example.com/promo.png",
  "caption": "Bonus bunga hingga 5,25% p.a."
}
```

**With everything**

```json
{
  "messageIdentifier": "img-1",
  "imageURL": "https://cdn.example.com/promo.png",
  "caption": "Bonus bunga hingga 5,25% p.a.",
  "aspectRatio": 1.6,
  "accessibilityText": "Amplop merah berisi koin"
}
```

| Field | What it adds |
| --- | --- |
| `aspectRatio` | Width ÷ height. |
| `accessibilityText` | What the picture shows, for VoiceOver. |

**Send `aspectRatio`.** It reserves the row's height before the download
lands. Without it the app assumes 16:9, and the conversation jumps when the
picture arrives and the row grows.

Omitting `accessibilityText` hides the picture from VoiceOver and lets the
caption speak for both, which is right when the picture only decorates.

**Permutations**

- No caption: send `"caption": ""`. The caption and its padding disappear
  together and the picture stands alone.
- Broken `imageURL`: the caption shows by itself. The sentence is the message;
  the picture only illustrates it.

## Choices

`custom_type: content.choices`

A question answered by picking and confirming.

**Minimal**

```json
{
  "messageIdentifier": "q-1",
  "choices": [
    { "identifier": "dining", "title": "Dining" },
    { "identifier": "travel", "title": "Hotel & Travel" }
  ]
}
```

**With everything**

```json
{
  "messageIdentifier": "q-1",
  "title": "Kategori apa yang diinginkan",
  "choices": [
    { "identifier": "dining", "title": "Dining", "prompt": "Promo dining" },
    { "identifier": "travel", "title": "Hotel", "prompt": "Promo hotel" }
  ],
  "allowsMultipleSelection": false,
  "submitTitle": "Kirim"
}
```

| Field | Default | What it adds |
| --- | --- | --- |
| `title` | none | The question, drawn above the chips. |
| `choices[].prompt` | the chip's `title` | What is sent when picked, when the label and the bot's phrasing differ. |
| `allowsMultipleSelection` | `true` | `false` makes each tap replace the selection. |
| `submitTitle` | `"Submit"` | The button's label. |

The answer is the selected prompts joined with `", "`, **in the order they
were offered** rather than tapped. A submitted card stays on screen and stops
accepting input.

Chips wrap to as many rows as they need, and a selected one grows to fit its
tick - so keep labels short if the rows should stay stable as they are picked.

**Choices or suggestions?** The submit button, not the number of choices. Use
`content.choices` whenever the customer should be able to change their mind;
use `response.suggestions` when one tap should send.

## Hand-off links

`custom_type: content.actions`

**Minimal**

```json
{
  "messageIdentifier": "act-1",
  "actions": [
    {
      "title": "Lihat Produk Sekarang",
      "action": {
        "identifier": "open-product",
        "deeplink": "ocbcid://mobile?type=product"
      }
    }
  ]
}
```

| Field | Default | What it adds |
| --- | --- | --- |
| `actions[].style` | `primary` | Underlined; `secondary` is not. Weight only — no behaviour, no permission. |
| `action.identifier` | required | Stable id for accessibility and analytics. **Not a destination.** |

An unparseable `deeplink` still reaches the host, which rejects it. It never
disappears while decoding: only the host knows which schemes the app owns.
| `action.deeplink` | required | The destination, passed to the host untouched. |

**No heading.** Whatever explains the hand-off is sent as an ordinary text
message before it. `title` and `detail` are no longer read.

An empty `actions[]` degrades to the update-required bubble: a card nobody can
act on is worse than an honest placeholder.

## Approval

`custom_type: content.approval`

The summary a customer checks before confirming. Confirm opens the PIN sheet.

**Minimal**

```json
{
  "messageIdentifier": "apv-1",
  "approvalIdentifier": "apv-1",
  "transactionIdentifier": "trx-99",
  "challengeIdentifier": "chg-99",
  "title": "Konfirmasi transfer Anda",
  "summary": [
    { "label": "Ke", "value": "Sample Beneficiary" },
    { "label": "Jumlah", "value": "IDR 1.250.000" }
  ],
  "expiresAt": "2026-09-20T09:00:00Z"
}
```

| Field | Default | What it adds |
| --- | --- | --- |
| `kind` | `generic` | Icon and wording: `transfer`, `currencyConversion`, `timeDeposit`, `savingsPlan`. |
| `notice` | none | The caveat line under the summary. |
| `handoff` | none | **Changes the flow** — see below. |

With `handoff`, Confirm hands off to a host screen and the in-feature PIN
sheet never opens. Without it, Confirm opens the sheet and the host's
authorization service runs.

`transactionIdentifier` and `challengeIdentifier` are passed to the host's
authorization service untouched. The package never reads them.

`expiresAt` is ISO8601. Other formats fail to decode.

## Status

`custom_type: content.status`

```json
{
  "messageIdentifier": "st-1",
  "title": "Selesai",
  "detail": "Permintaan Anda sudah diproses.",
  "level": "success"
}
```

`level`: `neutral`, `success`, `warning`, `error`. Anything else → `neutral`.

## Information

`custom_type: content.information`

```json
{
  "messageIdentifier": "inf-1",
  "title": "Limit transfer",
  "text": "Limit harian Anda saat ini.",
  "items": [
    { "label": "Sesama bank", "value": "IDR 100.000.000" }
  ]
}
```

`title` is optional; `items` may be empty, leaving only `text`.

## Receipt

`custom_type: content.receipt`

```json
{
  "messageIdentifier": "rcp-1",
  "title": "Transfer berhasil",
  "detail": "Dana sudah diteruskan.",
  "summary": [
    { "label": "Nomor referensi", "value": "TRX-99812" }
  ],
  "footnote": "Simpan nomor referensi ini."
}
```

`footnote` is optional.

## Chart

`custom_type: content.chart`

```json
{
  "messageIdentifier": "cht-1",
  "title": "Pengeluaran bulan ini",
  "chartType": "bar",
  "series": [
    { "label": "Makan", "value": 2500000, "formattedValue": "IDR 2,5jt" }
  ]
}
```

| Field | Default | What it adds |
| --- | --- | --- |
| `chartType` | `bar` | `bar`, `line`, `donut`, `progress`. |
| `subtitle`, `totalValue`, `footnote` | none | Context above and below. |

**`value` and `formattedValue` are both required and both used.** `value` is a
number and drives the geometry; `formattedValue` is the text drawn. Two fields
because the app must not format currency itself - the backend knows the locale,
the rounding and the bank's conventions.

## Portfolio

`custom_type: content.portfolio`

Same series shape as the chart, with a headline figure.

```json
{
  "messageIdentifier": "prt-1",
  "title": "Portofolio Anda",
  "totalValue": "IDR 128.400.000",
  "performanceText": "+4,2% sejak awal tahun",
  "allocations": [
    { "label": "Reksa dana", "value": 60, "formattedValue": "60%" }
  ]
}
```

## Financial list

`custom_type: content.financial-list`

```json
{
  "messageIdentifier": "lst-1",
  "title": "Dana masuk 30 hari terakhir",
  "style": "incoming",
  "rows": [
    {
      "title": "Gaji",
      "subtitle": "02 Jul",
      "value": "IDR 12.000.000",
      "tone": "positive"
    }
  ],
  "totalLabel": "Total",
  "totalValue": "IDR 12.000.000"
}
```

| Field | Values |
| --- | --- |
| `style` | `paidBills`, `incoming`, `holdings` |
| `rows[].tone` | `neutral`, `positive` |

`totalLabel`, `totalValue` and `totalCaption` are a set - send them together
or not at all. `rows[].subtitle` and `rows[].detail` are optional.

## Anything this app does not know

Any `content.*` name the app has never heard of.

```json
{
  "messageIdentifier": "future-1",
  "fallbackText": "Perbarui aplikasi untuk melihat kartu ini."
}
```

`fallbackText` is optional; omitted, the app supplies its own sentence. This
is what the `content.` prefix buys.

---

# Framing a reply

These are not bubbles. They open, fill and close a turn.

| Event | Payload | When |
| --- | --- | --- |
| `response.started` | `{ "messageIdentifier": "..." }` | A reply is coming. |
| `text.delta` | `{ "messageIdentifier": "...", "text": "..." }` | A chunk of it. Repeatable. |
| `response.completed` | `{ "messageIdentifier": "..." }` | **Required.** |
| `response.suggestions` | see below | Prompts offered with the reply. |
| `heartbeat` | `{}` | Keeps a quiet connection alive. |

Without `response.completed` the typing indicator never stops and the send
button stays as Stop. It is the single most common way a bot breaks the
screen.

## Suggestions

One tap sends. For a question that should wait for confirmation, use
`content.choices` instead.

```json
{
  "title": "Kategori apa yang diinginkan",
  "suggestions": [
    {
      "identifier": "incoming",
      "title": "Dana masuk",
      "prompt": "Tampilkan dana masuk"
    }
  ]
}
```

`title` is optional - it is the question the prompts answer, drawn above them
in the same bubble. A reply offering follow-ups that need no heading omits it.

---

# Rules that hold everywhere

**An unknown enum value falls back; it never fails.** A strange `chartType`
becomes `bar`, a strange `level` becomes `neutral`, a strange `style` becomes
`primary`. Same reason as the `content.` prefix: a backend newer than the app
must still produce something readable rather than a hole in the conversation.

**A malformed payload degrades to the update-required bubble.** It never tears
down the channel.

**History replays the same payloads.** Whatever carries a bubble live has to
survive into the history response, or a reopened conversation loses every card
it ever showed. The newest 100 messages are kept.

**Never send a PIN, a token, a full account number, or anything the customer
cannot already see on their screen.** This payload leaves the device and is
stored by whoever runs the bot.
