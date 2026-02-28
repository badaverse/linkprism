import Foundation

enum PatternType: String, Codable, CaseIterable {
    case host = "host"
    case regex = "regex"

    var displayName: String {
        switch self {
        case .host:  return String(localized: "Host")
        case .regex: return String(localized: "Regex")
        }
    }
}

struct Rule: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var patternType: PatternType
    var pattern: String
    var chromeProfile: String
    var shouldAsk: Bool = false
    var isEnabled: Bool = true
}
