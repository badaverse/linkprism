import Foundation

@Observable
final class URLRouter {
    static let shared = URLRouter()

    /// Set by routeURL when result is .ask — AppDelegate observes this to show the picker panel.
    var pendingPickerURL: URL?

    /// The rule ID associated with the pending picker request.
    var pendingRuleID: UUID?

    /// Dedup: last handled URL
    private var lastHandled: (url: String, time: Date)?

    func routeURL(_ url: URL) {
        let now = Date()
        if let last = lastHandled,
           last.url == url.absoluteString,
           now.timeIntervalSince(last.time) < 0.5 {
            return
        }
        lastHandled = (url.absoluteString, now)

        let targetURL: URL
        if url.scheme == "linkprism",
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let encoded = components.queryItems?.first(where: { $0.name == "url" })?.value,
           let decoded = URL(string: encoded) {
            targetURL = decoded
        } else {
            targetURL = url
        }

        // Only process http/https URLs through rules; open everything else (file://, etc.) directly
        guard targetURL.scheme == "http" || targetURL.scheme == "https" else {
            Router.openInChrome(url: targetURL, profile: nil)
            return
        }

        let config = ConfigManager.shared
        let result = Router.resolve(url: targetURL, rules: config.rules)

        switch result {
        case .open(let profile):
            Router.openInChrome(url: targetURL, profile: profile)
        case .ask(let ruleID):
            if let rememberedProfile = RememberedRouteManager.shared.lookup(url: targetURL) {
                Router.openInChrome(url: targetURL, profile: rememberedProfile)
            } else {
                pendingPickerURL = targetURL
                pendingRuleID = ruleID
            }
        case .none:
            Router.openInChrome(url: targetURL, profile: nil)
        }
    }
}
