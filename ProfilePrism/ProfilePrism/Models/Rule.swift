import Foundation

enum PatternType: String, Codable, CaseIterable {
    case host = "host"
    case regex = "regex"

    var displayName: String {
        switch self {
        case .host:  return "호스트"
        case .regex: return "정규식"
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
