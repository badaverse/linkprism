import SwiftUI

struct RuleEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let existingRule: Rule?
    let onSave: (Rule) -> Void

    @State private var patternType: PatternType
    @State private var pattern: String
    @State private var chromeProfile: String
    @State private var shouldAsk: Bool
    @State private var isEnabled: Bool
    @State private var availableProfiles: [ChromeProfile] = []
    @State private var regexError: String? = nil

    init(rule: Rule?, onSave: @escaping (Rule) -> Void) {
        self.existingRule = rule
        self.onSave = onSave
        _patternType    = State(initialValue: rule?.patternType   ?? .host)
        _pattern        = State(initialValue: rule?.pattern       ?? "")
        _chromeProfile  = State(initialValue: rule?.chromeProfile ?? "")
        _shouldAsk      = State(initialValue: rule?.shouldAsk     ?? false)
        _isEnabled      = State(initialValue: rule?.isEnabled     ?? true)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if existingRule == nil {
                Text("Add Rule").font(.headline)
            } else {
                Text("Edit Rule").font(.headline)
            }

            Picker("", selection: $patternType) {
                ForEach(PatternType.allCases, id: \.self) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: patternType) { _, _ in validateRegex() }

            VStack(alignment: .leading, spacing: 4) {
                if patternType == .host {
                    Text("Host")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Regex Pattern")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                TextField(
                    patternType == .host ? "e.g. notion.so or *.atlassian.net" : "e.g. .*\\.corp\\.com",
                    text: $pattern
                )
                .textFieldStyle(.roundedBorder)
                .onChange(of: pattern) { _, _ in validateRegex() }

                if let error = regexError {
                    Text(error)
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            Toggle("Ask which profile every time", isOn: $shouldAsk)

            if !shouldAsk {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chrome Profile Directory")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if availableProfiles.isEmpty {
                        TextField("e.g. Profile 2 or Default", text: $chromeProfile)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Picker("", selection: $chromeProfile) {
                            ForEach(availableProfiles) { p in
                                Text(p.email.isEmpty ? p.name : "\(p.email) (\(p.name))")
                                    .tag(p.directory)
                            }
                        }
                    }

                    Text("Directory: \(chromeProfile.isEmpty ? String(localized: "Not selected") : chromeProfile)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Toggle("Enable Rule", isOn: $isEnabled)

            Divider()

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Button("Save") { save() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(!canSave)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 380)
        .onAppear {
            availableProfiles = ChromeProfileScanner.scan()
            if chromeProfile.isEmpty, let first = availableProfiles.first {
                chromeProfile = first.directory
            }
        }
    }

    // MARK: - Helpers

    private var canSave: Bool {
        !pattern.isEmpty && (shouldAsk || !chromeProfile.isEmpty) && regexError == nil
    }

    private func validateRegex() {
        guard patternType == .regex, !pattern.isEmpty else {
            regexError = nil
            return
        }
        do {
            _ = try NSRegularExpression(pattern: pattern)
            regexError = nil
        } catch {
            regexError = String(localized: "Invalid regex: \(error.localizedDescription)")
        }
    }

    private func save() {
        let rule = Rule(
            id: existingRule?.id ?? UUID(),
            patternType: patternType,
            pattern: pattern,
            chromeProfile: shouldAsk ? "" : chromeProfile,
            shouldAsk: shouldAsk,
            isEnabled: isEnabled
        )
        onSave(rule)
        dismiss()
    }
}
