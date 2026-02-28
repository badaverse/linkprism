import SwiftUI

@main
struct ProfileRouterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("Profile Router 설정", id: "settings") {
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
