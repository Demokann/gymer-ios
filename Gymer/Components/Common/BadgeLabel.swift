// MARK: - BadgeLabel
// Owner: UI Designer Agent
// Last Modified: 28.04.2026
// Dependencies: DesignSystem/Colors, Models/Enums

import SwiftUI

struct BadgeLabel: View {
    enum BadgeType {
        case bodyRegion(BodyRegion)
        case setType(SetType)
        case personalRecord
        case custom(String, Color)
    }
    
    let type: BadgeType
    
    var body: some View {
        Text(text)
            .gymFont(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
    
    private var text: String {
        switch type {
        case .bodyRegion(let region):
            return region.displayName.uppercased()
        case .setType(let setType):
            return setType.rawValue.uppercased()
        case .personalRecord:
            return "🏆 PR"
        case .custom(let title, _):
            return title.uppercased()
        }
    }
    
    private var backgroundColor: Color {
        switch type {
        case .bodyRegion:
            return .gymMuted
        case .setType(let setType):
            return setType.color
        case .personalRecord:
            return .gymLime
        case .custom(_, let color):
            return color
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        BadgeLabel(type: .bodyRegion(.chest))
        BadgeLabel(type: .bodyRegion(.back))
        BadgeLabel(type: .setType(.warmUp))
        BadgeLabel(type: .setType(.dropSet))
        BadgeLabel(type: .personalRecord)
        BadgeLabel(type: .custom("Custom", .blue))
    }
    .padding()
    .background(Color.gymBlack)
}
