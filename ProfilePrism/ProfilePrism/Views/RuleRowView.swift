import SwiftUI

struct RuleRowView: View {
    let rule: Rule

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: rule.patternType == .host ? "globe" : "chevron.left.forwardslash.chevron.right")
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.pattern)
                    .font(.body)
                    .foregroundStyle(rule.isEnabled ? .primary : .secondary)
                Text(rule.patternType.displayName)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if rule.shouldAsk {
                Text("Ask")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            } else {
                Text(rule.chromeProfile)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue.opacity(0.12))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 3)
        .opacity(rule.isEnabled ? 1 : 0.45)
    }
}
