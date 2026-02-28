import Foundation
import Combine

final class ConfigManager: ObservableObject {
    static let shared = ConfigManager()

    @Published var rules: [Rule] = []
    @Published var defaultProfile: String = "Default"

    private let configURL: URL

    private init() {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appDir = appSupport.appendingPathComponent("ProfileRouter")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        configURL = appDir.appendingPathComponent("rules.json")
        load()
    }

    func load() {
        guard
            let data = try? Data(contentsOf: configURL),
            let stored = try? JSONDecoder().decode(StoredConfig.self, from: data)
        else { return }
        rules = stored.rules
        defaultProfile = stored.defaultProfile
    }

    func save() {
        let stored = StoredConfig(rules: rules, defaultProfile: defaultProfile)
        if let data = try? JSONEncoder().encode(stored) {
            try? data.write(to: configURL, options: .atomic)
        }
    }

    // MARK: - Stored shape

    private struct StoredConfig: Codable {
        var rules: [Rule]
        var defaultProfile: String
    }
}
