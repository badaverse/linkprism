import Foundation

struct RememberedRoute: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var ruleID: UUID
    var normalizedURL: String
    var chromeProfile: String
    var createdAt: Date
}
