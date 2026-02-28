import Testing
import Foundation
@testable import ProfilePrism

struct RememberedRouteManagerTests {

    // MARK: - URL Normalization

    @Test func normalizeStripsScheme() {
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "docs.google.com/document/d/abc123")
    }

    @Test func normalizeStripsQueryAndFragment() {
        let url = URL(string: "https://docs.google.com/document/d/abc123/edit?tab=t.0#heading=h.xxx")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "docs.google.com/document/d/abc123")
    }

    @Test func normalizeStripsEditSuffix() {
        let url = URL(string: "https://docs.google.com/spreadsheets/d/xyz789/edit")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "docs.google.com/spreadsheets/d/xyz789")
    }

    @Test func normalizeStripsPreviewSuffix() {
        let url = URL(string: "https://docs.google.com/document/d/abc123/preview")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "docs.google.com/document/d/abc123")
    }

    @Test func normalizePreservesGitHubPath() {
        let url = URL(string: "https://github.com/org/repo/pull/42")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "github.com/org/repo/pull/42")
    }

    @Test func normalizeStripsTrailingSlash() {
        let url = URL(string: "https://notion.so/workspace/page-abc123/")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "notion.so/workspace/page-abc123")
    }

    @Test func normalizeHandlesViewSuffix() {
        let url = URL(string: "https://docs.google.com/document/d/abc123/view")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "docs.google.com/document/d/abc123")
    }

    // MARK: - CRUD Operations

    @Test func lookupReturnsNilWhenEmpty() {
        let manager = makeManager()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        #expect(manager.lookup(url: url) == nil)
    }

    @Test func rememberAndLookup() {
        let manager = makeManager()
        let url = URL(string: "https://docs.google.com/document/d/abc123/edit")!
        manager.remember(url: url, profile: "Profile 2")
        #expect(manager.lookup(url: url) == "Profile 2")
    }

    @Test func rememberUpdatesExistingEntry() {
        let manager = makeManager()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        manager.remember(url: url, profile: "Profile 2")
        manager.remember(url: url, profile: "Profile 3")
        #expect(manager.entries.count == 1)
        #expect(manager.lookup(url: url) == "Profile 3")
    }

    @Test func lookupMatchesDespiteDifferentSuffix() {
        let manager = makeManager()
        let editURL = URL(string: "https://docs.google.com/document/d/abc123/edit")!
        let previewURL = URL(string: "https://docs.google.com/document/d/abc123/preview")!
        manager.remember(url: editURL, profile: "Profile 2")
        #expect(manager.lookup(url: previewURL) == "Profile 2")
    }

    @Test func forgetRemovesEntry() {
        let manager = makeManager()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        manager.remember(url: url, profile: "Profile 2")
        let id = manager.entries[0].id
        manager.forget(id: id)
        #expect(manager.entries.isEmpty)
        #expect(manager.lookup(url: url) == nil)
    }

    @Test func clearAllRemovesEverything() {
        let manager = makeManager()
        manager.remember(url: URL(string: "https://a.com/1")!, profile: "P1")
        manager.remember(url: URL(string: "https://b.com/2")!, profile: "P2")
        manager.clearAll()
        #expect(manager.entries.isEmpty)
    }

    @Test func persistenceRoundTrip() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let manager1 = RememberedRouteManager(fileURL: fileURL)
        manager1.remember(url: URL(string: "https://docs.google.com/document/d/abc123")!, profile: "Profile 2")

        let manager2 = RememberedRouteManager(fileURL: fileURL)
        #expect(manager2.entries.count == 1)
        #expect(manager2.entries[0].chromeProfile == "Profile 2")
    }

    // MARK: - Helpers

    private func makeManager() -> RememberedRouteManager {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        return RememberedRouteManager(fileURL: fileURL)
    }
}
