import Testing
import Foundation
@testable import LinkPrism

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
        #expect(result == "docs.google.com/document/d/abc123/edit")
    }

    @Test func normalizePreservesFullPath() {
        let url = URL(string: "https://github.com/org/repo/pull/42")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "github.com/org/repo/pull/42")
    }

    @Test func normalizeStripsTrailingSlash() {
        let url = URL(string: "https://notion.so/workspace/page-abc123/")!
        let result = RememberedRouteManager.normalize(url: url)
        #expect(result == "notion.so/workspace/page-abc123")
    }

    // MARK: - CRUD Operations

    @Test func lookupReturnsNilWhenEmpty() {
        let manager = makeManager()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        #expect(manager.lookup(url: url) == nil)
    }

    @Test func rememberAndLookup() {
        let manager = makeManager()
        let ruleID = UUID()
        let url = URL(string: "https://docs.google.com/document/d/abc123/edit")!
        manager.remember(url: url, profile: "Profile 2", ruleID: ruleID)
        #expect(manager.lookup(url: url) == "Profile 2")
    }

    @Test func rememberUpdatesExistingEntry() {
        let manager = makeManager()
        let ruleID = UUID()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        manager.remember(url: url, profile: "Profile 2", ruleID: ruleID)
        manager.remember(url: url, profile: "Profile 3", ruleID: ruleID)
        #expect(manager.entries.count == 1)
        #expect(manager.lookup(url: url) == "Profile 3")
    }

    @Test func lookupDistinguishesDifferentPaths() {
        let manager = makeManager()
        let ruleID = UUID()
        let editURL = URL(string: "https://docs.google.com/document/d/abc123/edit")!
        let previewURL = URL(string: "https://docs.google.com/document/d/abc123/preview")!
        manager.remember(url: editURL, profile: "Profile 2", ruleID: ruleID)
        #expect(manager.lookup(url: previewURL) == nil)
    }

    @Test func forgetRemovesEntry() {
        let manager = makeManager()
        let ruleID = UUID()
        let url = URL(string: "https://docs.google.com/document/d/abc123")!
        manager.remember(url: url, profile: "Profile 2", ruleID: ruleID)
        let id = manager.entries[0].id
        manager.forget(id: id)
        #expect(manager.entries.isEmpty)
        #expect(manager.lookup(url: url) == nil)
    }

    @Test func clearAllRemovesEverything() {
        let manager = makeManager()
        let ruleID = UUID()
        manager.remember(url: URL(string: "https://a.com/1")!, profile: "P1", ruleID: ruleID)
        manager.remember(url: URL(string: "https://b.com/2")!, profile: "P2", ruleID: ruleID)
        manager.clearAll()
        #expect(manager.entries.isEmpty)
    }

    @Test func persistenceRoundTrip() {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let ruleID = UUID()
        let manager1 = RememberedRouteManager(fileURL: fileURL)
        manager1.remember(url: URL(string: "https://docs.google.com/document/d/abc123")!, profile: "Profile 2", ruleID: ruleID)

        let manager2 = RememberedRouteManager(fileURL: fileURL)
        #expect(manager2.entries.count == 1)
        #expect(manager2.entries[0].chromeProfile == "Profile 2")
        #expect(manager2.entries[0].ruleID == ruleID)
    }

    // MARK: - Rule-based Filtering

    @Test func entriesForRuleIDFiltersCorrectly() {
        let manager = makeManager()
        let ruleA = UUID()
        let ruleB = UUID()
        manager.remember(url: URL(string: "https://a.com/1")!, profile: "P1", ruleID: ruleA)
        manager.remember(url: URL(string: "https://b.com/2")!, profile: "P2", ruleID: ruleB)
        manager.remember(url: URL(string: "https://c.com/3")!, profile: "P3", ruleID: ruleA)

        let entriesA = manager.entries(for: ruleA)
        #expect(entriesA.count == 2)
        #expect(entriesA.allSatisfy { $0.ruleID == ruleA })

        let entriesB = manager.entries(for: ruleB)
        #expect(entriesB.count == 1)
        #expect(entriesB[0].ruleID == ruleB)
    }

    @Test func forgetAllForRuleIDRemovesOnlyMatchingEntries() {
        let manager = makeManager()
        let ruleA = UUID()
        let ruleB = UUID()
        manager.remember(url: URL(string: "https://a.com/1")!, profile: "P1", ruleID: ruleA)
        manager.remember(url: URL(string: "https://b.com/2")!, profile: "P2", ruleID: ruleB)
        manager.remember(url: URL(string: "https://c.com/3")!, profile: "P3", ruleID: ruleA)

        manager.forgetAll(for: ruleA)

        #expect(manager.entries.count == 1)
        #expect(manager.entries[0].ruleID == ruleB)
        #expect(manager.entries[0].chromeProfile == "P2")
    }

    @Test func forgetAllForRuleIDWithNoMatchesIsNoOp() {
        let manager = makeManager()
        let ruleA = UUID()
        let ruleB = UUID()
        manager.remember(url: URL(string: "https://a.com/1")!, profile: "P1", ruleID: ruleA)

        manager.forgetAll(for: ruleB)

        #expect(manager.entries.count == 1)
    }

    // MARK: - Helpers

    private func makeManager() -> RememberedRouteManager {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".json")
        return RememberedRouteManager(fileURL: fileURL)
    }
}
