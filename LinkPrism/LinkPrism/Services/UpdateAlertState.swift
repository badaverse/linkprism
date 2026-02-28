import Foundation
import AppKit

enum UpdateAlertState {
    static func checkForUpdates() {
        Task { @MainActor in
            let result = await UpdateChecker.check()
            switch result {
            case .upToDate:
                let alert = NSAlert()
                alert.messageText = String(localized: "You're up to date")
                alert.informativeText = String(localized: "You're running the latest version.")
                alert.alertStyle = .informational
                alert.addButton(withTitle: String(localized: "OK"))
                alert.runModal()
            case .updateAvailable(let release):
                let alert = NSAlert()
                alert.messageText = String(localized: "Update Available")
                let version = release.tagName.replacingOccurrences(of: "v", with: "")
                alert.informativeText = String(localized: "LinkPrism \(version) is available for download.\n\n\(release.body)")
                alert.alertStyle = .informational
                alert.addButton(withTitle: String(localized: "Download"))
                alert.addButton(withTitle: String(localized: "Later"))
                if alert.runModal() == .alertFirstButtonReturn {
                    if let url = UpdateChecker.dmgDownloadURL(from: release) {
                        NSWorkspace.shared.open(url)
                    }
                }
            case .error(let message):
                let alert = NSAlert()
                alert.messageText = String(localized: "Update Check Failed")
                alert.informativeText = message
                alert.alertStyle = .warning
                alert.addButton(withTitle: String(localized: "OK"))
                alert.runModal()
            }
        }
    }
}
