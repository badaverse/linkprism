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
            Text(existingRule == nil ? "규칙 추가" : "규칙 편집")
                .font(.headline)

            // 패턴 타입 선택
            Picker("", selection: $patternType) {
                ForEach(PatternType.allCases, id: \.self) {
                    Text($0.displayName).tag($0)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: patternType) { _, _ in validateRegex() }

            // 패턴 입력
            VStack(alignment: .leading, spacing: 4) {
                Text(patternType == .host ? "호스트" : "정규식 패턴")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField(
                    patternType == .host ? "예: notion.so 또는 *.atlassian.net" : "예: .*\\.corp\\.com",
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

            // 물어보기 토글
            Toggle("열 때마다 프로필 물어보기", isOn: $shouldAsk)

            // 프로필 선택 (물어보기가 꺼져있을 때만)
            if !shouldAsk {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Chrome 프로필 디렉토리")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if availableProfiles.isEmpty {
                        TextField("예: Profile 2 또는 Default", text: $chromeProfile)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Picker("", selection: $chromeProfile) {
                            ForEach(availableProfiles) { p in
                                Text(p.email.isEmpty ? p.name : "\(p.email) (\(p.name))")
                                    .tag(p.directory)
                            }
                        }
                    }

                    Text("폴더명 기준: \(chromeProfile.isEmpty ? "선택 안 됨" : chromeProfile)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Toggle("규칙 활성화", isOn: $isEnabled)

            Divider()

            HStack {
                Spacer()
                Button("취소") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])
                Button("저장") { save() }
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(!canSave)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(20)
        .frame(width: 380)
        .onAppear {
            availableProfiles = ChromeProfileScanner.scan()
            // 스캔된 프로필이 있고 아직 선택 안 했으면 첫 번째로 기본값
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
            regexError = "유효하지 않은 정규식: \(error.localizedDescription)"
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
