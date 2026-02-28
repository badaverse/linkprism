import Foundation

struct GitHubRelease: Decodable {
    let tagName: String
    let name: String
    let body: String
    let htmlUrl: String
    let assets: [Asset]

    struct Asset: Decodable {
        let name: String
        let browserDownloadUrl: String
        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadUrl = "browser_download_url"
        }
    }

    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name, body
        case htmlUrl = "html_url"
        case assets
    }
}

enum UpdateCheckResult {
    case upToDate
    case updateAvailable(release: GitHubRelease)
    case error(String)
}

enum UpdateChecker {
    // TODO: Replace with actual GitHub repo
    private static let repoOwner = "OWNER"
    private static let repoName = "profile-prism"

    static func check() async -> UpdateCheckResult {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest"
        guard let url = URL(string: urlString) else {
            return .error(String(localized: "Invalid URL"))
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return .error(String(localized: "Server response error"))
            }
            let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
            let latestVersion = release.tagName
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: "v", with: "")
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
            if latestVersion.compare(currentVersion, options: .numeric) == .orderedDescending {
                return .updateAvailable(release: release)
            } else {
                return .upToDate
            }
        } catch {
            return .error(String(localized: "Network error: \(error.localizedDescription)"))
        }
    }

    static func dmgDownloadURL(from release: GitHubRelease) -> URL? {
        if let dmg = release.assets.first(where: { $0.name.hasSuffix(".dmg") }) {
            return URL(string: dmg.browserDownloadUrl)
        }
        return URL(string: release.htmlUrl)
    }
}
