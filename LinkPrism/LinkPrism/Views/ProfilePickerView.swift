import SwiftUI

struct ProfilePickerView: View {
    let url: URL
    let profiles: [ChromeProfile]
    let onSelect: (String, Bool) -> Void
    let onCancel: () -> Void

    @State private var rememberChoice = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("Select Profile")
                    .font(.headline)
                Text(RememberedRouteManager.normalize(url: url))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()

            ScrollView {
                VStack(spacing: 2) {
                    ForEach(profiles) { profile in
                        Button(action: { onSelect(profile.directory, rememberChoice) }) {
                            HStack(spacing: 10) {
                                Image(systemName: "person.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)

                                VStack(alignment: .leading, spacing: 1) {
                                    Text(profile.name)
                                        .font(.body)
                                    if !profile.email.isEmpty {
                                        Text(profile.email)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }

                                Spacer()

                                Text(profile.directory)
                                    .font(.caption2)
                                    .foregroundStyle(.quaternary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.primary.opacity(0.00001))
                        )
                        .onHover { hovering in
                            if hovering {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                    }
                }
                .padding(6)
            }

            Divider()

            HStack {
                Toggle("Don't ask again for this URL", isOn: $rememberChoice)
                    .toggleStyle(.checkbox)
                    .font(.caption)
                Spacer()
                Button("Cancel") { onCancel() }
                    .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 300, height: min(CGFloat(profiles.count) * 52 + 140, 400))
    }
}
