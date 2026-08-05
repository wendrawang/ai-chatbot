# Performance and lifecycle baseline

Measured on a sanitized Debug build using an iPhone 17 Pro simulator running
iOS 26.5. Simulator measurements are directional; the production gate remains
a Release build on the oldest supported physical iPhone.

## Automated fixtures

| Check | Fixture | Gate |
| --- | --- | --- |
| Scroll cadence | 2,000 stable message rows | At least 97% of same-process idle baseline |
| Conversation ingestion | 5,000 typed messages | Completes with clock and memory metrics |
| Large graph release | ViewModel plus 5,000 rows | Every weak reference becomes `nil` |
| UI stress | 5,000 rows plus suggestions | Latest row visible and list remains scrollable |
| Stream parser | 1,000 SSE events | Clock and memory metrics collected |
| Chat lifecycle | Active request then release | Request cancelled and ViewModel released |
| PIN lifecycle | Active authorization then release | Request cancelled and ViewModel released |
| Feature lifecycle | Hosted SwiftUI root released | Hosting graph released |

`CADisplayLink` timestamps are used instead of wall-clock start/stop time so the
FPS calculation does not count partial intervals. Simulator throughput varies
with host load, so the test records an idle baseline immediately before active
scrolling and rejects a rendering regression greater than 3%. A Release build
on a 60 Hz-capable physical device remains the absolute 60 FPS gate.

## Rendering decisions

- `LazyVStack` creates only rows near the viewport.
- Each message has a stable ID and its own observable ViewModel.
- A streamed delta changes one row rather than replacing the conversation.
- Text deltas are coalesced in a 40 ms buffer.
- Message lookup is dictionary-backed instead of an O(n) array scan.
- Suggestions trigger bottom alignment only while the user follows the latest
  message; deliberate history reading is not interrupted.
- Bottom scrolling is coalesced and settled in bounded passes so a 5,000-row
  lazy height estimate reaches the final message without retaining every row.
- The router owns no view controllers and creates history or PIN state only
  when requested.

## Memory-leak check

Run:

```sh
cd Packages/TanyaAI
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:TanyaAIPerformanceTests/TanyaAILifecycleTests
```

A passing weak-reference test proves that the tested graph released. It does
not prove that every future host adapter is leak-free.

## FPS and stress checks

```sh
cd Packages/TanyaAI
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild test \
  -scheme TanyaAI-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:TanyaAIPerformanceTests
```

Read `TANYA_AI_BASELINE_FPS` and `TANYA_AI_SCROLL_FPS` from the output. Launch
the sandbox with `--stress-chat` to exercise the 5,000-message UI fixture.

Latest simulator evidence on 5 August 2026:

- 53.28 FPS idle baseline and 53.88 FPS while scrolling 2,000 rows;
- 5,000-message ingestion completed in 0.11–0.21 seconds across three runs;
- process peak physical memory stayed between 38.38 and 38.41 MB;
- all five weak-reference lifecycle tests released their tested graphs;
- the UI reached message 5,000 and remained responsive through 16 rapid swipes.

## Production gate

1. Profile a Release build on the oldest supported physical iPhone.
2. Use Instruments Leaks and Allocations for 25 open, stream, approve, dismiss
   cycles.
3. Use Core Animation or Organizer hitch metrics while rapidly scrolling the
   2,000- and 5,000-message fixtures.
4. Repeat with Low Power Mode, Dynamic Type, VoiceOver, and a slow network.
5. Confirm memory returns to a stable baseline after each group of five cycles.

No architecture can guarantee 60 FPS on every device, thermal state, or future
bubble implementation. New complex rows must rerun these gates before merge.
