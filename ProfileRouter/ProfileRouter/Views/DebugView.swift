import SwiftUI

#if DEBUG
struct DebugView: View {
    @EnvironmentObject var config: ConfigManager
    @State private var urlString = "https://"
    @State private var result: DebugResult?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("URL 라우팅 테스트")
                .font(.headline)

            HStack {
                TextField("URL 입력", text: $urlString)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { test() }

                Button("테스트") { test() }
                    .keyboardShortcut(.return, modifiers: [])
            }

            if let r = result {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    row("URL", r.url)
                    row("Host", r.host)
                    row("매칭 규칙", r.matchedRule ?? "없음")
                    row("결과", r.action)

                    if let profile = r.profile {
                        row("프로필", profile)
                    }
                }
                .font(.callout)

                Divider()

                HStack {
                    Spacer()
                    Button("실제로 열기") {
                        guard let url = URL(string: urlString) else { return }
                        let routeResult = Router.resolve(url: url, rules: config.rules)
                        switch routeResult {
                        case .open(let profile):
                            Router.openInChrome(url: url, profile: profile)
                        case .ask:
                            Router.openInChrome(url: url, profile: nil)
                        case .none:
                            Router.openInChrome(url: url, profile: nil)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(20)
        .frame(width: 420)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 70, alignment: .trailing)
            Text(value)
                .textSelection(.enabled)
        }
    }

    private func test() {
        guard let url = URL(string: urlString) else {
            result = DebugResult(
                url: urlString,
                host: "-",
                matchedRule: nil,
                action: "잘못된 URL",
                profile: nil
            )
            return
        }

        let host = url.host ?? ""
        let routeResult = Router.resolve(url: url, rules: config.rules)

        // 매칭된 규칙 찾기
        var matchedPattern: String?
        for rule in config.rules where rule.isEnabled {
            if matchesRule(host: host, rule: rule) {
                matchedPattern = "\(rule.patternType.displayName): \(rule.pattern)"
                break
            }
        }

        let action: String
        var profile: String?
        switch routeResult {
        case .open(let p):
            action = "프로필로 열기"
            profile = p
        case .ask:
            action = "물어보기"
        case .none:
            action = "기본 Chrome (매칭 없음)"
        }

        result = DebugResult(
            url: url.absoluteString,
            host: host,
            matchedRule: matchedPattern,
            action: action,
            profile: profile
        )
    }

    private func matchesRule(host: String, rule: Rule) -> Bool {
        switch rule.patternType {
        case .host:
            if rule.pattern.hasPrefix("*.") {
                let base = String(rule.pattern.dropFirst(2))
                return host == base || host.hasSuffix("." + base)
            }
            return host == rule.pattern
        case .regex:
            guard let regex = try? NSRegularExpression(pattern: rule.pattern) else { return false }
            let range = NSRange(host.startIndex..., in: host)
            return regex.firstMatch(in: host, range: range) != nil
        }
    }
}

private struct DebugResult {
    let url: String
    let host: String
    let matchedRule: String?
    let action: String
    let profile: String?
}
#endif
