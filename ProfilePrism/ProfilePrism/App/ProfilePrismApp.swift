import SwiftUI

@main
struct ProfilePrismApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // MARK: - Settings

        Settings {
            SettingsView()
                .environmentObject(ConfigManager.shared)
                .onOpenURL { url in
                    URLRouter.shared.routeURL(url)
                }
        }

        // MARK: - Help

        Window(String(localized: "ProfilePrism Help"), id: "help") {
            HelpView()
        }
        .defaultSize(width: 520, height: 500)

        // MARK: - Onboarding

        Window(String(localized: "Get Started with ProfilePrism"), id: "onboarding") {
            OnboardingView(onComplete: {
                UserDefaults.standard.set(true, forKey: "didShowWelcome")
                DispatchQueue.main.async {
                    for window in NSApp.windows
                        where window.identifier?.rawValue == "onboarding" {
                        window.close()
                    }
                }
            })
        }
        .windowResizability(.contentSize)

        // MARK: - Debug

        #if DEBUG
        Window(String(localized: "URL Test"), id: "debug") {
            DebugView()
                .environmentObject(ConfigManager.shared)
        }
        .defaultSize(width: 420, height: 260)
        #endif

        // MARK: - Menu Bar

        MenuBarExtra("ProfilePrism", image: "MenuBarIcon") {
            MenuBarContent()
        }
    }
}
