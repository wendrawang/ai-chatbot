import SwiftUI

/// Stand-in for an existing screen the host already owns.
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
        .navigationBarTitle(destination.title, displayMode: .inline)
        .legacyAccessibilityIdentifier("deeplink.target")
    }
}
