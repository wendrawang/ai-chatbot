# Session refactor validation — 10 October 2026

## Implemented behavior

The channel accepts new prompts while the agent is typing. SDK submission acknowledgements are separate from incoming bot messages; no backend Stop or reply-correlation capability is assumed. Initial history gates sending, channel failures expose Retry, and failed local messages can be retried in the same row. Local editor state does not publish keystrokes to the chat model.

The list uses native UIHostingConfiguration on iOS 16+, with explicit controller containment on the iOS 15 fallback. Reuse/teardown clears hosted content; row callbacks hold the screen model weakly. Mixed text/image/HTML lifecycle tests exercise 25 render-and-release cycles. The UIKit editor and SwiftUI text use the same typography leading.

## Verified checks

- DesignKit: 60 tests passed on iPhone 17 / iOS 26.5 simulator, including legacy containment/reuse and WebKit navigation tests. The navigation test now mounts a real-sized web view in a window; detached zero-sized web views did not consistently attempt automatic redirects.
- TanyaAI: 162 tests passed on the same simulator, including mixed 25-cycle lifecycle, history/error/retry, independent send acknowledgements, option consumption and rendering.
- Sandbox UI: 12 tests passed on iPhone 17 Pro / iOS 26.5 simulator, including send during typing, composer line limits/long words, radio consumption, scrolling to latest, all bubble scenarios, PIN and legacy navigation.
- Tencent adapter: 24 assertions passed using production contracts and an SDK double; 5 Python REST/script tests passed without external chat operations.
- Four Tencent root Swift files typechecked against the real SDK 9.1.7818 framework with iOS 15 deployment. Sendbird/ThreeDolphins examples typechecked against local API doubles; those checks do not certify vendor runtime behavior.
- SwiftLint and physical file/method checks passed. The formatter check passed with generated tokens excluded; the generated token diff is empty.

## Simulator profiling and limits

A manual `--showcase` process was profiled on the iPhone 17 / iOS 26.5 simulator using Instruments 27.0 on macOS 27.0.1:

- Time Profiler recording: about 15.6 seconds after fixture rendering. The exported potential-hangs table contained no rows in that interval. Instruments reported a missing-input-table warning, so this is a limited idle observation.
- Leaks + Allocations recording: about 20.6 seconds. Classic allocation/leak counters were not available through the structured CLI export, so no zero-leak total is claimed from this recording. A separate `leaks` CLI scan did not complete and was stopped.
- A 3-second process sample reported a 36.6 MB physical footprint (44.5 MB peak); the sampled main thread was waiting in the run loop. This is one idle snapshot, not a stress-test ceiling and not the combined footprint of WebKit child processes.
- The automated cadence check uses the median of three CADisplayLink samples and a 55-callback/s threshold. It is a regression proxy, not a measurement of rendered GPU FPS.

Trace/sample artifacts on the implementation machine: `/tmp/session-cpu-final.trace`, `/tmp/session-leaks.trace`, `/tmp/session-idle-cpu-sample.txt`, and `/tmp/session-hangs.xml`. Xcode result bundles are under `/tmp/session-designkit-mounted.xcresult` and `/tmp/session-package-final-complete.xcresult`; the complete UI run is `/tmp/session-ui-final-complete.xcresult`.

## Production device gate

The connected iPhone was offline. Before production rollout, run the real host and Tencent SDK on an accessible device: login, restore, rapid prompt/context changes, send failure/retry, scroll mixed bubbles during streaming, keyboard/Dynamic Type, theme change between presentations, and 25 open/close cycles. Inspect Allocations/Leaks for retained feature graphs and growth after cache warm-up, plus Animation Hitches for real frame performance. The simulator and SDK doubles cannot establish real-device Tencent/WebKit memory behavior.

No SDK login, message send, or group creation against Tencent servers was performed by these validation runs.
