# Performance and lifecycle baseline

Measured on the sanitized Debug build using an iPhone 17 Pro simulator running
iOS 26.5. Results are directional and are not a substitute for profiling a
Release build on the oldest supported physical device.

## Latest automated result

| Check | Fixture | Result |
| --- | --- | --- |
| Scroll frame rate | 120 stable message rows | 60.40 FPS |
| Stream parser | 1,000 SSE events | 7 ms average |
| Parser process peak | XCTest process | 47.86 MB |
| Parser memory delta | Per measured iteration | 0 KB |
| Chat lifecycle | Active request then release | Passed |
| PIN lifecycle | Active authorization then release | Passed |
| Full feature graph | Container loaded then released | Passed |
| UI showcase | 11+ bubbles and PIN sheet | Passed |

The frame-rate assertion allows a minimum of 55 measured frames per second to
avoid simulator scheduling noise while targeting a 60 FPS display link.

## Production gate

Before release, repeat the scroll and streaming tests on the oldest supported
physical iPhone with a Release build. Use Instruments Allocations and Leaks for
repeated open, stream, approve, dismiss cycles. Also test a paginated history
with the product team's maximum supported conversation length.
