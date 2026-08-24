# Examples

Reference code for integrating Tanya AI into a real host application.

Nothing in this folder belongs to a build target. `Scripts/generate_project.rb`
only collects sources from `TanyaAISandboxApp`, and `Scripts/check_style.sh`
and `.swiftlint.yml` only scan the sandbox app, the UI tests, and the package.
These files are meant to be copied into a host project and renamed, not
compiled here.

| Folder | Host shape |
| --- | --- |
| [`NavigationViewHost/Minimal`](NavigationViewHost/Minimal) | Smallest wiring that makes the feature work: two thin adapters and one modifier |
| [`NavigationViewHost/Production`](NavigationViewHost/Production) | Release-ready version: pinning, expiry checks, host theme, presentation gateway |
| [`NavigationViewHost/Deeplink`](NavigationViewHost/Deeplink) | Handing a bubble action to the host's existing deeplink handler, minimal and full |

Both target the same host shape — SwiftUI `NavigationView` screens hosted from
`AppDelegate` and `SceneDelegate`.

The sandbox target stays the executable proof: it exercises the same
integration path end to end with mock adapters. These examples show the same
path with the host's own networking, authorization, and design system.
