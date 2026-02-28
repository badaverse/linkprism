import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 96, height: 96)

            VStack(spacing: 4) {
                Text("ProfilePrism")
                    .font(.title2.bold())
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("Made by badaverse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Automatically routes URLs to the right\nChrome profile based on domain rules.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/badaverse/profileprism")!) {
                    Label("GitHub", systemImage: "link")
                }

                Button(String(localized: "Check for Updates")) {
                    UpdateAlertState.checkForUpdates()
                }
            }

            Spacer()

            Text("MIT License")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
