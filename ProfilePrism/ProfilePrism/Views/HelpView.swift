import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hostPatternSection()
                Divider()
                regexPatternSection()
                Divider()
                askFeatureSection()
                Divider()
                chromeProfileDirectorySection()
                Divider()
                chromeExtensionSection()
            }
            .padding(24)
        }
        .frame(minWidth: 480, minHeight: 400)
    }

    // MARK: - Host Pattern Matching

    private func hostPatternSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Host Pattern Matching")
                .font(.headline)

            Text("Rules are evaluated from top to bottom. The first matching rule is applied.")
                .font(.body)

            Text("Exact Match")
                .font(.subheadline)
                .bold()

            Text("Matches when the hostname is an exact match.")
                .font(.body)

            Text("atlassian.net")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("Wildcard Match")
                .font(.subheadline)
                .bold()

            Text("Use * to match subdomains.")
                .font(.body)

            Text("*.atlassian.net")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("This pattern matches all subdomains such as jira.atlassian.net, confluence.atlassian.net, etc.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Regex Pattern

    private func regexPatternSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regex Pattern")
                .font(.headline)

            Text("Supports regex patterns using NSRegularExpression. Regex is matched against the hostname only.")
                .font(.body)

            Text("Example:")
                .font(.body)
                .bold()

            Text(".*\\.corp\\.example\\.com")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("This pattern matches all subdomains of corp.example.com.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Ask Feature

    private func askFeatureSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ask Feature")
                .font(.headline)

            Text("When a rule's action is set to \"Ask\", a profile picker will appear each time the URL is opened.")
                .font(.body)

            Text("This is useful for domains used in multiple contexts (e.g., GitHub, Google Docs). You can choose which profile to use each time.")
                .font(.body)
        }
    }

    // MARK: - Finding Chrome Profile Directory

    private func chromeProfileDirectorySection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Finding Chrome Profile Directory")
                .font(.headline)

            Text("ProfilePrism automatically detects Chrome profile directories. To check manually:")
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                Text("1. Enter the following URL in Chrome's address bar:")
                    .font(.body)

                Text("chrome://version")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)

                Text("2. The last folder name in the \"Profile Path\" field is the profile directory.")
                    .font(.body)

                Text("e.g. /Users/username/Library/Application Support/Google/Chrome/Profile 1")
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)

                Text("In the path above, \"Profile 1\" is the profile directory name.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Chrome Extension

    private func chromeExtensionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Chrome Extension")
                .font(.headline)

            Text("Chrome handles link clicks internally, so macOS default browser settings alone cannot redirect links clicked within Chrome to ProfilePrism.")
                .font(.body)

            Text("Why the Extension is Needed")
                .font(.subheadline)
                .bold()

            Text("The Chrome extension intercepts links clicked within Chrome and forwards them to ProfilePrism via the profileprism:// scheme.")
                .font(.body)

            Text("profileprism://route?url=<encoded_url>")
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)

            Text("Installation")
                .font(.subheadline)
                .bold()

            VStack(alignment: .leading, spacing: 4) {
                Text("1. Open chrome://extensions in Chrome.")
                    .font(.body)
                Text("2. Enable \"Developer mode\".")
                    .font(.body)
                Text("3. Click \"Load unpacked\".")
                    .font(.body)
                Text("4. Select the ProfilePrism extension folder.")
                    .font(.body)
            }
        }
    }
}

#Preview {
    HelpView()
}
