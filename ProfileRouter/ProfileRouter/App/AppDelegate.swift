import AppKit
import Carbon
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem!
    private var welcomePopover: NSPopover?
    private var pickerWindow: NSWindow?
    #if DEBUG
    private var debugWindow: NSWindow?
    #endif

    /// 최근 처리한 URL (중복 호출 방지용)
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

        // 메뉴바 앱이므로 시작 시 설정창을 띄우지 않음
        DispatchQueue.main.async {
            for window in NSApp.windows where window.title.contains("설정") {
                window.close()
            }
        }

        // 최초 실행 시 안내 팝오버
        if !UserDefaults.standard.bool(forKey: "didShowWelcome") {
            UserDefaults.standard.set(true, forKey: "didShowWelcome")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showWelcomePopover()
            }
        }
    }

    // MARK: - 메뉴바 아이콘

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            let image = NSImage(named: "MenuBarIcon")
            image?.isTemplate = true
            button.image = image
            button.image?.accessibilityDescription = "Profile Router"
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "설정 열기",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))
        #if DEBUG
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "🛠 URL 테스트",
            action: #selector(openDebug),
            keyEquivalent: "d"
        ))
        #endif
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "종료",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        ))
        statusItem.menu = menu
    }

    // MARK: - 첫 실행 팝오버

    private func showWelcomePopover() {
        guard let button = statusItem.button else { return }

        let popover = NSPopover()
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: VStack(spacing: 8) {
                Image("MenuBarIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.secondary)
                Text("Profile Router가\n메뉴바에서 실행 중입니다")
                    .multilineTextAlignment(.center)
                    .font(.callout)
            }
            .padding(16)
        )
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        welcomePopover = popover

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.welcomePopover?.close()
            self?.welcomePopover = nil
        }
    }

    // MARK: - 설정 열기

    @objc private func openSettings() {
        for window in NSApp.windows where window.title.contains("설정") {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate()
            return
        }
    }

    // MARK: - URL 처리

    func routeURL(_ url: URL) {
        let now = Date()
        if let last = lastHandled,
           last.url == url.absoluteString,
           now.timeIntervalSince(last.time) < 0.5 {
            return
        }
        lastHandled = (url.absoluteString, now)

        // profilerouter://route?url=<encoded_url> 형식 처리
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

    // MARK: - 프로필 선택 창

    private func showProfilePicker(for url: URL) {
        // 이전 창이 있으면 닫기
        pickerWindow?.close()

        let profiles = ChromeProfileScanner.scan()
        guard !profiles.isEmpty else {
            // 프로필을 찾을 수 없으면 기본으로 열기
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
        window.title = "프로필 선택"
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

    // MARK: - 디버그

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
        window.title = "URL 테스트"
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

    // MARK: - 윈도우 관리

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
