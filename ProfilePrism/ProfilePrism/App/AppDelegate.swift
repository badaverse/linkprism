import AppKit
import Carbon
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var onboardingWindow: NSWindow?
    private var pickerWindow: NSWindow?
    private var helpWindow: NSWindow?
    #if DEBUG
    private var debugWindow: NSWindow?
    #endif

    /// Dedup: last handled URL
    private var lastHandled: (url: String, time: Date)?

    // MARK: - Lifecycle

    func applicationWillFinishLaunching(_ notification: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:replyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()

        // Menu bar app — close settings window on launch
        DispatchQueue.main.async {
            for window in NSApp.windows where window.identifier?.rawValue == "settings" {
                window.close()
            }
        }

        // First-run onboarding
        if !UserDefaults.standard.bool(forKey: "didShowWelcome") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding()
            }
        }
    }

    // MARK: - Status Bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let image = NSImage(named: "MenuBarIcon")
            image?.isTemplate = true
            button.image = image
            button.image?.accessibilityDescription = "ProfilePrism"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: String(localized: "Open Settings"),
            action: #selector(openSettings),
            keyEquivalent: ","
        ))
        menu.addItem(NSMenuItem(
            title: String(localized: "Help"),
            action: #selector(openHelp),
            keyEquivalent: "?"
        ))
        menu.addItem(NSMenuItem(
            title: String(localized: "Check for Updates"),
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        ))
        #if DEBUG
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: String(localized: "URL Test"),
            action: #selector(openDebug),
            keyEquivalent: "d"
        ))
        #endif
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: String(localized: "Quit"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        statusItem.menu = menu
    }

    // MARK: - Onboarding

    private func showOnboarding() {
        let onboarding = OnboardingView(onComplete: { [weak self] in
            UserDefaults.standard.set(true, forKey: "didShowWelcome")
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
        })

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "Get Started with ProfilePrism")
        window.contentView = NSHostingView(rootView: onboarding)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()

        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            UserDefaults.standard.set(true, forKey: "didShowWelcome")
            self?.onboardingWindow = nil
        }

        onboardingWindow = window
    }

    // MARK: - Open Settings

    @objc private func openSettings() {
        for window in NSApp.windows where window.identifier?.rawValue == "settings" {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }
    }

    // MARK: - URL Handling

    func routeURL(_ url: URL) {
        let now = Date()
        if let last = lastHandled,
           last.url == url.absoluteString,
           now.timeIntervalSince(last.time) < 0.5 {
            return
        }
        lastHandled = (url.absoluteString, now)

        // profilerouter://route?url=<encoded_url>
        let targetURL: URL
        if url.scheme == "profilerouter",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let encoded = components.queryItems?.first(where: { $0.name == "url" })?.value,
           let decoded = URL(string: encoded) {
            targetURL = decoded
        } else {
            targetURL = url
        }

        let config = ConfigManager.shared
        let result = Router.resolve(url: targetURL, rules: config.rules)

        switch result {
        case .open(let profile):
            Router.openInChrome(url: targetURL, profile: profile)
        case .ask:
            showProfilePicker(for: targetURL)
        case .none:
            Router.openInChrome(url: targetURL, profile: nil)
        }
    }

    // MARK: - Profile Picker

    private func showProfilePicker(for url: URL) {
        pickerWindow?.close()

        let profiles = ChromeProfileScanner.scan()
        guard !profiles.isEmpty else {
            Router.openInChrome(url: url, profile: nil)
            return
        }

        let picker = ProfilePickerView(
            url: url,
            profiles: profiles,
            onSelect: { [weak self] profile in
                Router.openInChrome(url: url, profile: profile)
                self?.pickerWindow?.close()
                self?.pickerWindow = nil
            },
            onCancel: { [weak self] in
                self?.pickerWindow?.close()
                self?.pickerWindow = nil
            }
        )

        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 340),
            styleMask: [.titled, .closable, .hudWindow, .utilityWindow],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "Select Profile")
        window.contentView = NSHostingView(rootView: picker)
        window.isFloatingPanel = true
        window.level = .floating
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()

        pickerWindow = window
    }

    @objc private func handleURLEvent(
        _ event: NSAppleEventDescriptor,
        replyEvent: NSAppleEventDescriptor
    ) {
        guard
            let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: urlString)
        else { return }

        routeURL(url)
    }

    // MARK: - Help

    @objc private func openHelp() {
        if let w = helpWindow {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 500),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        window.title = String(localized: "ProfilePrism Help")
        window.contentView = NSHostingView(rootView: HelpView())
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
        helpWindow = window
    }

    // MARK: - Updates

    @objc private func checkForUpdates() {
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
                alert.informativeText = String(localized: "ProfilePrism \(version) is available for download.\n\n\(release.body)")
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

    // MARK: - Debug

    #if DEBUG
    @objc private func openDebug() {
        if let w = debugWindow {
            w.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 260),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = String(localized: "URL Test")
        window.contentView = NSHostingView(
            rootView: DebugView()
                .environmentObject(ConfigManager.shared)
        )
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate()
        debugWindow = window
    }
    #endif

    // MARK: - Window Management

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
