import SwiftUI

/// Stand-in for an existing screen the host already owns.
///
/// Shows the deeplink that reached it so the demo makes the hand-off visible.
struct SandboxDeeplinkTargetScreen: View {
    let destination: SandboxDeeplinkDestination

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reached through the host deeplink")
                    .font(.headline)
                Text(
                    "The legacy stack returned to the dashboard first, then " +
                    "pushed this screen."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)

                Text(destination.deeplink)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .legacyAccessibilityIdentifier("deeplink.url")

                ForEach(destination.sortedParameters) { parameter in
                    HStack {
                        Text(parameter.name)
                            .foregroundColor(.secondary)
                        Spacer(minLength: 12)
                        Text(parameter.value)
                    }
                    .font(.subheadline)
                }
            }
            .padding(20)
        }
        .navigationBarTitle(Text(destination.title), displayMode: .inline)
        .legacyAccessibilityIdentifier("deeplink.target")
    }
}
