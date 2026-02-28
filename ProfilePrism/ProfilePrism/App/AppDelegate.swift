import AppKit
import Carbon
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var onboardingWindow: NSWindow?
    private var pickerWindow: NSWindow?

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
        // First-run onboarding
        if !UserDefaults.standard.bool(forKey: "didShowWelcome") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showOnboarding()
            }
        }

        // Observe URLRouter for picker requests
        observePickerRequests()
    }

    // MARK: - URL Handling

    @objc private func handleURLEvent(
        _ event: NSAppleEventDescriptor,
        replyEvent: NSAppleEventDescriptor
    ) {
        guard
            let urlString = event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue,
            let url = URL(string: urlString)
        else { return }

        URLRouter.shared.routeURL(url)
    }

    // MARK: - Onboarding

    private func showOnboarding() {
        let onboarding = OnboardingView(onComplete: { [weak self] in
            UserDefaults.standard.set(true, forKey: "didShowWelcome")
            DispatchQueue.main.async {
                self?.onboardingWindow?.close()
                self?.onboardingWindow = nil
            }
        })

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 380),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
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

    // MARK: - Profile Picker (NSPanel — floating, no SwiftUI equivalent)

    private func observePickerRequests() {
        withObservationTracking {
            _ = URLRouter.shared.pendingPickerURL
        } onChange: { [weak self] in
            DispatchQueue.main.async {
                self?.handlePickerRequest()
                self?.observePickerRequests()
            }
        }
    }

    private func handlePickerRequest() {
        guard let url = URLRouter.shared.pendingPickerURL else { return }
        let ruleID = URLRouter.shared.pendingRuleID
        URLRouter.shared.pendingPickerURL = nil
        URLRouter.shared.pendingRuleID = nil
        showProfilePicker(for: url, ruleID: ruleID)
    }

    private func showProfilePicker(for url: URL, ruleID: UUID?) {
        pickerWindow?.close()

        let profiles = ChromeProfileScanner.scan()
        guard !profiles.isEmpty else {
            Router.openInChrome(url: url, profile: nil)
            return
        }

        let picker = ProfilePickerView(
            url: url,
            profiles: profiles,
            onSelect: { [weak self] profile, shouldRemember in
                if shouldRemember, let ruleID {
                    RememberedRouteManager.shared.remember(url: url, profile: profile, ruleID: ruleID)
                }
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

    // MARK: - Window Management

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
