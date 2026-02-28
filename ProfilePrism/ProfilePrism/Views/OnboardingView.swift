import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    let onComplete: () -> Void
    private let totalSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch currentStep {
                case 0: step1Introduction
                case 1: step2DefaultBrowser
                case 2: step3ChromeExtension
                default: EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(24)

            Divider()

            HStack {
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { i in
                        Circle()
                            .fill(i == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 7, height: 7)
                    }
                }
                Spacer()
                if currentStep > 0 {
                    Button("Previous") { withAnimation { currentStep -= 1 } }
                }
                if currentStep < totalSteps - 1 {
                    Button("Next") { withAnimation { currentStep += 1 } }
                        .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") { onComplete() }
                        .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .frame(width: 480, height: 440)
    }

    private var step1Introduction: some View {
        VStack(spacing: 16) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)
            Text("Welcome to ProfilePrism")
                .font(.title2.bold())
            Text("A macOS menu bar app that automatically\nroutes URLs to the right Chrome profile.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 10) {
                featureRow(icon: "globe", text: String(localized: "Auto-select Chrome profile by domain"))
                featureRow(icon: "arrow.triangle.branch", text: String(localized: "Host, wildcard, and regex pattern support"))
                featureRow(icon: "questionmark.circle", text: String(localized: "\"Ask\" mode to choose profile each time"))
            }
            .padding(.top, 8)
        }
    }

    private var step2DefaultBrowser: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe.americas.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Set as Default Browser")
                .font(.title2.bold())
            Text("ProfilePrism needs to be set as the\ndefault web browser to receive URLs.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.Desktop-Settings.extension") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Text("System Settings \u{2192} Desktop & Dock \u{2192} Default web browser\nSelect \"ProfilePrism\".")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private var step3ChromeExtension: some View {
        VStack(spacing: 16) {
            Image(systemName: "puzzlepiece.extension.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text("Chrome Extension")
                .font(.title2.bold())
            Text("Links clicked inside Chrome bypass the default\nbrowser, so ProfilePrism can't intercept them.\nInstall the extension to solve this.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .font(.callout)
            VStack(alignment: .leading, spacing: 8) {
                stepRow(number: 1, text: String(localized: "Download the extension zip from GitHub Releases"))
                stepRow(number: 2, text: String(localized: "Unzip the downloaded file"))
                stepRow(number: 3, text: String(localized: "Open chrome://extensions and enable \"Developer mode\""))
                stepRow(number: 4, text: String(localized: "Click \"Load unpacked\" and select the unzipped folder"))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(.secondary.opacity(0.08)))
            Text("You can install the extension later from the Help page.")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(text).font(.callout)
        }
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(spacing: 10) {
            Text("\(number)")
                .font(.caption.bold())
                .frame(width: 20, height: 20)
                .background(Circle().fill(.blue.opacity(0.15)))
                .foregroundStyle(.blue)
            Text(text).font(.callout)
        }
    }
}
