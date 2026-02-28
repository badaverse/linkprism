import SwiftUI

enum SettingsTab: String, CaseIterable, Identifiable {
    case routing
    case remembered
    case about

    var id: String { rawValue }

    var label: String {
        switch self {
        case .routing: String(localized: "Routing")
        case .remembered: String(localized: "Remembered")
        case .about: String(localized: "About")
        }
    }

    var icon: String {
        switch self {
        case .routing: "arrow.triangle.branch"
        case .remembered: "clock.arrow.circlepath"
        case .about: "info.circle"
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var selectedTab: SettingsTab = .routing

    var body: some View {
        NavigationSplitView {
            List(SettingsTab.allCases, selection: $selectedTab) { tab in
                Label(tab.label, systemImage: tab.icon)
                    .tag(tab)
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 140, ideal: 160, max: 200)
        } detail: {
            switch selectedTab {
            case .routing:
                ContentView()
                    .environmentObject(config)
            case .remembered:
                RememberedURLsView()
            case .about:
                AboutView()
            }
        }
        .frame(minWidth: 580, idealWidth: 700, minHeight: 400, idealHeight: 500)
        .background(WindowResizableHelper())
    }
}

private struct WindowResizableHelper: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.styleMask.insert(.resizable)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
