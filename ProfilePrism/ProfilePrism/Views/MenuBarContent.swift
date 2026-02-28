import SwiftUI

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings

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

    private func bringToFront() {
        // Delay to let SwiftUI create the window after the menu dismisses.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.windows.first { $0.isVisible }?.makeKeyAndOrderFront(nil)
        }
    }
}
