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
                Text("LinkPrism")
                    .font(.title2.bold())
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("Made by badaverse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Stop juggling Chrome profiles.\nLet your links find their way home.", comment: "App tagline in About view")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/badaverse/linkprism")!) {
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
