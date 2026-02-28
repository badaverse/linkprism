import SwiftUI

@main
struct ProfilePrismApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("Profile Router Settings", id: "settings") {
            ContentView()
                .environmentObject(ConfigManager.shared)
                .onOpenURL { url in
                    appDelegate.routeURL(url)
                }
        }
        .defaultSize(width: 540, height: 420)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
