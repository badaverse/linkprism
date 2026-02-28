import Foundation

struct ChromeProfile: Identifiable, Hashable {
    var id: String { directory }
    let directory: String   // "Default", "Profile 1", …
    let name: String        // 실제 Google 계정 이름 또는 사용자 지정 이름
    let email: String       // Google 계정 이메일 (표시용)
}

enum ChromeProfileScanner {
    static func scan() -> [ChromeProfile] {
        let chromePath = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Google/Chrome")

        // Chrome 실행 중엔 개별 Preferences 파일이 잠기므로
        // 모든 프로필 정보가 담긴 Local State를 사용
        let localStatePath = chromePath.appendingPathComponent("Local State")

        guard
            let data = try? Data(contentsOf: localStatePath),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let profileSection = json["profile"] as? [String: Any],
            let infoCache = profileSection["info_cache"] as? [String: [String: Any]]
        else {
            return fallbackScan(chromePath: chromePath)
        }

        return infoCache
            .compactMap { (directory, info) -> ChromeProfile? in
                // gaia_name: 실제 Google 계정 이름
                // name: 사용자가 직접 설정한 프로필 이름
                let gaiaName    = info["gaia_name"] as? String ?? ""
                let profileName = info["name"] as? String ?? ""
                let email       = info["user_name"] as? String ?? ""

                let displayName = gaiaName.isEmpty ? profileName : gaiaName
                guard !displayName.isEmpty else { return nil }

                return ChromeProfile(directory: directory, name: displayName, email: email)
            }
            .sorted { lhs, rhs in
                if lhs.directory == "Default" { return true }
                if rhs.directory == "Default" { return false }
                return lhs.directory < rhs.directory
            }
    }

    // MARK: - Fallback

    private static func fallbackScan(chromePath: URL) -> [ChromeProfile] {
        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: chromePath,
            includingPropertiesForKeys: nil
        ) else { return [] }

        return contents
            .compactMap { url -> ChromeProfile? in
                let dir = url.lastPathComponent
                guard dir == "Default" || dir.hasPrefix("Profile ") else { return nil }
                return ChromeProfile(directory: dir, name: dir, email: "")
            }
            .sorted { lhs, rhs in
                if lhs.directory == "Default" { return true }
                if rhs.directory == "Default" { return false }
                return lhs.directory < rhs.directory
            }
    }
}
