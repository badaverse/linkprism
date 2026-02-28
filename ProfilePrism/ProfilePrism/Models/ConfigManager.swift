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
        let appDir = appSupport.appendingPathComponent("ProfilePrism")
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

    // MARK: - Export / Import

    struct ExportBundle: Codable {
        var version: Int = 1
        var exportedAt: Date
        var rules: [Rule]
        var defaultProfile: String
        var rememberedRoutes: [RememberedRoute]
    }

    func exportBundle() -> ExportBundle {
        ExportBundle(
            exportedAt: Date(),
            rules: rules,
            defaultProfile: defaultProfile,
            rememberedRoutes: RememberedRouteManager.shared.entries
        )
    }

    func applyImport(_ bundle: ExportBundle) {
        rules = bundle.rules
        defaultProfile = bundle.defaultProfile
        save()
        RememberedRouteManager.shared.replaceAll(with: bundle.rememberedRoutes)
    }

    // MARK: - Stored shape

    private struct StoredConfig: Codable {
        var rules: [Rule]
        var defaultProfile: String
    }
}
