# Component and screen conventions

Use SwiftUI by default. Use native hosting configuration for table cells on iOS 16+, with explicit controller containment as the iOS 15 fallback. Keep UIKit behind focused bridges when the iOS 15 requirement or measured behavior requires them. DesignKit depends on no feature or SDK; TanyaAI owns session and transaction policy.

## Ownership and dependency injection

Use `let` for display inputs, `@Binding` for a value owned by the caller, and `@State`/`@FocusState` for editing or local interaction. Computed values need no stored state. A ViewModel belongs to a screen workflow with async work or business decisions; do not introduce one for every card, button, or composer. Inject callbacks for actions. Protocols belong at replaceable I/O boundaries such as a chat session.

UI owners and public UIKit entry points are `@MainActor`. Repositories serialize incoming events and deliver them on the main queue. Do not store credentials/PIN or log message payloads in UI diagnostics. A `weak` capture is required where ownership would form a cycle; immutable configuration can be captured strongly.

Own long-lived feature models once, outside `body`. `@StateObject` owns a SwiftUI model; `@ObservedObject` reads an externally owned model. The chat composer owns its draft in its private SwiftUI section, so typing does not publish changes to the message graph.

## Names and declaration order

Name components by role: `MessageComposer`, `OptionRow`, `SummaryCard`. A `View` suffix is optional for semantic component names; keep the established name within a component family. Use `Screen` for a page, `Sheet` for a modal, `ViewController` for UIKit, and `ViewModel` only for workflow/state owners. Use generic names in DesignKit. Feature-specific payload adapters belong in TanyaAIPresentation.

Private visual sections are nouns: `header`, `content`, `footer`, `actionButton`. Parameterized helpers describe the item: `row(for:)`, `label(for:)`. Extract a dedicated `struct View` when reused, when it owns local state, or when it needs a separate dependency/update boundary. A computed `some View` property organizes code; it does not isolate observation by itself.

Order declarations as environment, binding/state, immutable inputs/callbacks, initializer, body, private visual sections, then helpers. Extension files describe one responsibility and match the declaring type (for example `MessageTableView+Coordinator`). Respect 250 physical lines per file, 50 per method, 120 per line. Split by responsibility rather than introducing generic `Helpers`/`Misc` files or compressing code to satisfy limits.

## Layout, resources, and styling

The component owns inner padding, fill, stroke, and shadow. The screen owns outer margins and placement. For a framed surface, order modifiers as layout/inner padding → background/stroke/shadow → outer margin → accessibility. Multiple padding modifiers are appropriate when they implement these distinct boundaries.

Use available `FigmaSize` values directly for padding/spacing. Define missing values by role in non-generated metrics. Never use a radius token as spacing just because the numbers match. Use `.sizeInArtwork` for artwork dimensions, `.strokeInArtwork` for drawn edges, and `.tapTargetInArtwork` for touch areas. Opacity is dimensionless and is not artwork-scaled. Keep the 375×812 reference; generated files are engine-owned.

SwiftUI text uses `.designFont(role)`; the UIKit editor receives the same font and leading. Visual dimensions may follow Figma while touch areas remain at least 44 points. A visual send circle of 24 does not imply a 24-point touch target. The composer deliberately has a white surface with text resolved for light appearance. Other surfaces follow the selected theme. Respect Dynamic Type and Reduce Motion.

UI copy is localized or supplied by the host; protocol names, symbol names, and accessibility identifiers are not copy. Assets/fonts belong in package resources and load from `Bundle.module`; host resources use validated names with semantic fallback. Never force unwrap a host font or asset lookup.

## Review and formatting

Run `Scripts/format_changed.py` before review. It uses the Xcode-bundled `swift-format` with `.swift-format`, includes new/changed Swift files, and excludes engine-owned tokens. Formatting is not a substitute for `Scripts/check_style.sh`, UI verification, or lifecycle tests. Run `Scripts/format_changed.py --check` in CI against the intended base ref using `--base <ref>`.

Tests cover observable behavior and lifetime, not one test per computed property. UI tests cover width/line limits, scrolling, selection, and sending during typing. Performance reports distinguish display-link callback cadence from rendered FPS and distinguish simulator results from device measurements. Release validation includes a real SDK/device pass.
