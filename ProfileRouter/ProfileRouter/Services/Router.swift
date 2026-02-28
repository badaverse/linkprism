import Foundation
import AppKit

enum RouteResult {
    case open(profile: String)   // 특정 프로필로 바로 열기
    case ask                     // 사용자에게 프로필 선택 요청
    case none                    // 매칭 없음 → Chrome 기본 동작
}

enum Router {
    /// URL을 규칙과 대조하여 라우팅 결과를 반환합니다.
    static func resolve(url: URL, rules: [Rule]) -> RouteResult {
        let host = url.host ?? ""

        for rule in rules where rule.isEnabled {
            if matches(host: host, rule: rule) {
                if rule.shouldAsk {
                    return .ask
                }
                return .open(profile: rule.chromeProfile)
            }
        }
        return .none
    }

    static func openInChrome(url: URL, profile: String?) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")

        var args = ["-na", "Google Chrome", "--args", "--no-default-browser-check"]
        if let profile {
            args.append("--profile-directory=\(profile)")
        }
        args.append(url.absoluteString)

        task.arguments = args
        try? task.run()
    }

    // MARK: - Private

    private static func matches(host: String, rule: Rule) -> Bool {
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
