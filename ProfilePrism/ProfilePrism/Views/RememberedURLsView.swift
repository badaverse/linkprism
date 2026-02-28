import SwiftUI

struct RememberedURLsView: View {
    @ObservedObject private var manager = RememberedRouteManager.shared
    @State private var selectedID: UUID?
    @State private var profileNames: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            entryList
            Divider()
            footer
        }
        .onAppear { loadProfileNames() }
    }

    private func loadProfileNames() {
        let profiles = ChromeProfileScanner.scan()
        profileNames = Dictionary(uniqueKeysWithValues: profiles.map { ($0.directory, $0.name) })
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Remembered URLs"))
                    .font(.title3.bold())
                Text(String(localized: "URLs you chose to remember from the profile picker."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - List

    private var entryList: some View {
        Group {
            if manager.entries.isEmpty {
                VStack {
                    Spacer()
                    Text(String(localized: "No remembered URLs yet."))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "When you select a profile and check \"Remember this URL\", it will appear here."))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List(selection: $selectedID) {
                    ForEach(manager.entries) { entry in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.normalizedURL)
                                    .font(.body)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Text(profileNames[entry.chromeProfile] ?? entry.chromeProfile)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .tag(entry.id)
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                manager.forget(id: entry.id)
                            }
                        }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .onDeleteCommand {
                    if let id = selectedID {
                        manager.forget(id: id)
                        selectedID = nil
                    }
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 0) {
            Button(action: {
                if let id = selectedID {
                    manager.forget(id: id)
                    selectedID = nil
                }
            }) {
                Image(systemName: "minus")
                    .frame(width: 28, height: 24)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(String(localized: "Delete Selected"))
            .disabled(selectedID == nil)

            Spacer()

            if !manager.entries.isEmpty {
                Button(String(localized: "Clear All")) {
                    manager.clearAll()
                    selectedID = nil
                }
                .font(.caption)
            }
        }
        .frame(height: 24)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}
