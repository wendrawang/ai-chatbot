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

Every pending confirmation exposes the same `Confirm` intent. The internal
UIKit coordinator lazily presents the numeric PIN bottom sheet. PIN values are
short-lived presentation state and never become chat content or stream data.

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
