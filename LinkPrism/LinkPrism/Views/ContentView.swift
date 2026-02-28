import SwiftUI

struct ContentView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var selectedRuleID: UUID? = nil
    @State private var showingAddRule = false
    @State private var editingRule: Rule? = nil
    @State private var profileNames: [String: String] = [:]

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ruleList
            Divider()
            footer
            if let selectedRule = config.rules.first(where: { $0.id == selectedRuleID }),
               selectedRule.shouldAsk {
                Divider()
                rememberedPanel(for: selectedRule)
            }
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
                Text(String(localized: "Routing Rules"))
                    .font(.title3.bold())
                Text(String(localized: "Rules are matched in order from top. The first match is used."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Rule List

    private var ruleList: some View {
        List(selection: $selectedRuleID) {
            ForEach(config.rules) { rule in
                RuleRowView(rule: rule, profileDisplayName: profileNames[rule.chromeProfile])
                    .tag(rule.id)
                    .contextMenu {
                        Button("Edit") { editingRule = rule }
                        Toggle("Enabled", isOn: Binding(
                            get: { rule.isEnabled },
                            set: { newValue in toggleEnabled(rule: rule, to: newValue) }
                        ))
                        Divider()
                        Button("Delete", role: .destructive) { delete(rule: rule) }
                    }
            }
            .onMove { config.rules.move(fromOffsets: $0, toOffset: $1); config.save() }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onDeleteCommand(perform: deleteSelected)
        .sheet(isPresented: $showingAddRule) {
            RuleEditorView(rule: nil) { newRule in
                config.rules.append(newRule)
                config.save()
            }
        }
        .sheet(item: $editingRule) { rule in
            RuleEditorView(rule: rule) { updated in
                if let idx = config.rules.firstIndex(where: { $0.id == updated.id }) {
                    config.rules[idx] = updated
                    config.save()
                }
            }
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 0) {
            footerButton(icon: "plus", help: "Add Rule") {
                showingAddRule = true
            }

            Divider().frame(height: 16)

            footerButton(icon: "minus", help: "Delete Selected Rule") {
                deleteSelected()
            }
            .disabled(selectedRuleID == nil)

            Divider().frame(height: 16)

            footerButton(icon: "pencil", help: "Edit Selected Rule") {
                editingRule = config.rules.first { $0.id == selectedRuleID }
            }
            .disabled(selectedRuleID == nil)

            Spacer()
        }
        .frame(height: 24)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }

    private func footerButton(icon: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 28, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(help)
    }

    // MARK: - Remembered URLs Panel

    private func rememberedPanel(for rule: Rule) -> some View {
        let entries = RememberedRouteManager.shared.entries(for: rule.id)
        return VStack(spacing: 0) {
            HStack {
                Text(String(localized: "Remembered URLs"))
                    .font(.caption.bold())
                Spacer()
                if !entries.isEmpty {
                    Button(String(localized: "Clear All")) {
                        RememberedRouteManager.shared.forgetAll(for: rule.id)
                    }
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            if entries.isEmpty {
                Text(String(localized: "No remembered URLs for this rule."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 8)
            } else {
                List {
                    ForEach(entries) { entry in
                        HStack {
                            Text(entry.normalizedURL)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Text(profileNames[entry.chromeProfile] ?? entry.chromeProfile)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .contextMenu {
                            Button("Delete", role: .destructive) {
                                RememberedRouteManager.shared.forget(id: entry.id)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .frame(maxHeight: 120)
            }
        }
    }

    // MARK: - Actions

    private func deleteSelected() {
        guard let id = selectedRuleID else { return }
        RememberedRouteManager.shared.forgetAll(for: id)
        config.rules.removeAll { $0.id == id }
        selectedRuleID = nil
        config.save()
    }

    private func delete(rule: Rule) {
        RememberedRouteManager.shared.forgetAll(for: rule.id)
        config.rules.removeAll { $0.id == rule.id }
        if selectedRuleID == rule.id { selectedRuleID = nil }
        config.save()
    }

    private func toggleEnabled(rule: Rule, to newValue: Bool) {
        if let idx = config.rules.firstIndex(where: { $0.id == rule.id }) {
            config.rules[idx].isEnabled = newValue
            config.save()
        }
    }
}
