import SwiftUI
import UniformTypeIdentifiers

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    @EnvironmentObject var config: ConfigManager

    var body: some View {
        Button(String(localized: "Open Settings")) {
            openSettings()
            bringToFront()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button(String(localized: "Help")) {
            openWindow(id: "help")
            bringToFront()
        }
        .keyboardShortcut("?", modifiers: .command)

        Divider()

        Button(String(localized: "Export Rules…")) {
            exportRules()
        }

        Button(String(localized: "Import Rules…")) {
            importRules()
        }

        Divider()

        Button(String(localized: "Check for Updates")) {
            UpdateAlertState.checkForUpdates()
        }

        #if DEBUG
        Divider()
        Button(String(localized: "URL Test")) {
            openWindow(id: "debug")
            bringToFront()
        }
        .keyboardShortcut("d", modifiers: .command)
        #endif

        Divider()

        Button(String(localized: "Quit")) {
            NSApp.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }

    // MARK: - Export

    private func exportRules() {
        let panel = NSSavePanel()
        panel.title = String(localized: "Export Rules")
        panel.nameFieldStringValue = "LinkPrism-Rules.linkprism"
        panel.allowedContentTypes = [.linkPrism]
        panel.canCreateDirectories = true

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let bundle = config.exportBundle()
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        do {
            let data = try encoder.encode(bundle)
            try data.write(to: url, options: .atomic)
        } catch {
            showAlert(
                title: String(localized: "Export Failed"),
                message: error.localizedDescription
            )
        }
    }

    // MARK: - Import

    private func importRules() {
        let panel = NSOpenPanel()
        panel.title = String(localized: "Import Rules")
        panel.allowedContentTypes = [.linkPrism]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let bundle: ConfigManager.ExportBundle
        do {
            let data = try Data(contentsOf: url)
            bundle = try decoder.decode(ConfigManager.ExportBundle.self, from: data)
        } catch {
            showAlert(
                title: String(localized: "Import Failed"),
                message: String(localized: "The file could not be read. It may be corrupted or in an unsupported format.")
            )
            return
        }

        let existingCount = config.rules.count
        let importCount = bundle.rules.count
        let alert = NSAlert()
        alert.messageText = String(localized: "Import Rules?")
        alert.informativeText = String(localized: "Your existing \(existingCount) rules will be replaced with \(importCount) imported rules. This cannot be undone.")
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "Import"))
        alert.addButton(withTitle: String(localized: "Cancel"))

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        config.applyImport(bundle)
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "OK"))
        alert.runModal()
    }

    private func bringToFront() {
        // Delay to let SwiftUI create the window after the menu dismisses.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first { $0.isVisible }?.makeKeyAndOrderFront(nil)
        }
    }
}

// MARK: - UTType

extension UTType {
    static let linkPrism = UTType(exportedAs: "com.badaverse.linkprism.rules")
}
