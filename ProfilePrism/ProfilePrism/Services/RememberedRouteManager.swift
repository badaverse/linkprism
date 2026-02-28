import Foundation

final class RememberedRouteManager: ObservableObject {
    static let shared = RememberedRouteManager()

    @Published var entries: [RememberedRoute] = []

    private let fileURL: URL

    private init() {
        let appSupport = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appDir = appSupport.appendingPathComponent("ProfilePrism")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        fileURL = appDir.appendingPathComponent("remembered.json")
        load()
    }

    // Internal init for testing
    init(fileURL: URL) {
        self.fileURL = fileURL
        load()
    }

    // MARK: - Public API

    func lookup(url: URL) -> String? {
        let key = Self.normalize(url: url)
        return entries.first(where: { $0.normalizedURL == key })?.chromeProfile
    }

    func remember(url: URL, profile: String) {
        let key = Self.normalize(url: url)
        // Update existing entry if present
        if let idx = entries.firstIndex(where: { $0.normalizedURL == key }) {
            entries[idx].chromeProfile = profile
            entries[idx].createdAt = Date()
        } else {
            entries.append(RememberedRoute(
                normalizedURL: key,
                chromeProfile: profile,
                createdAt: Date()
            ))
        }
        save()
    }

    func forget(id: UUID) {
        entries.removeAll { $0.id == id }
        save()
    }

    func clearAll() {
        entries.removeAll()
        save()
    }

    // MARK: - URL Normalization

    private static let trailingSegments: Set<String> = [
        "edit", "preview", "view", "copy"
    ]

    static func normalize(url: URL) -> String {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            ?? URLComponents()
        // Strip scheme, query, fragment
        components.scheme = nil
        components.query = nil
        components.fragment = nil

        let host = components.host ?? ""
        var path = components.path

        // Remove trailing slash
        while path.hasSuffix("/") {
            path = String(path.dropLast())
        }

        // Remove known trailing segments (e.g. /edit, /preview)
        let lastSegment = path.split(separator: "/").last.map(String.init) ?? ""
        if trailingSegments.contains(lastSegment) {
            path = String(path.prefix(upTo: path.index(path.endIndex, offsetBy: -(lastSegment.count + 1))))
        }

        // Remove trailing slash again after stripping segment
        while path.hasSuffix("/") {
            path = String(path.dropLast())
        }

        return host + path
    }

    // MARK: - Persistence

    private func load() {
        guard
            let data = try? Data(contentsOf: fileURL),
            let decoded = try? JSONDecoder().decode([RememberedRoute].self, from: data)
        else { return }
        entries = decoded
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
