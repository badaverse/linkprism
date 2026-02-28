import SwiftUI

struct ContentView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var selectedRuleID: UUID? = nil
    @State private var showingAddRule = false
    @State private var editingRule: Rule? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ruleList
            Divider()
            footer
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("ProfilePrism")
                    .font(.title3.bold())
                Text("Rules are matched in order from top. The first match is used.")
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
                RuleRowView(rule: rule)
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
        HStack(spacing: 4) {
            Button(action: { showingAddRule = true }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .help("Add Rule")

            Button(action: deleteSelected) {
                Image(systemName: "minus")
            }
            .buttonStyle(.plain)
            .disabled(selectedRuleID == nil)
            .help("Delete Selected Rule")

            Button(action: {
                editingRule = config.rules.first { $0.id == selectedRuleID }
            }) {
                Image(systemName: "pencil")
            }
            .buttonStyle(.plain)
            .disabled(selectedRuleID == nil)
            .help("Edit Selected Rule")

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Actions

    private func deleteSelected() {
        guard let id = selectedRuleID else { return }
        config.rules.removeAll { $0.id == id }
        selectedRuleID = nil
        config.save()
    }

    private func delete(rule: Rule) {
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
