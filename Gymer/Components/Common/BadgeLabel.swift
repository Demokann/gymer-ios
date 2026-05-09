// MARK: - BadgeLabel
// Owner: UI Designer Agent
// Last Modified: 06.05.2026
// Dependencies: DesignSystem/Colors, Models/Enums

import SwiftUI

struct BadgeLabel: View {
    enum Style {
        case system
        case region
        case warmUp
        case dropSet
        case failure
        case pr
        case custom
    }
    
    let text: String
    let style: Style
    var customColor: Color? = nil
    
    var body: some View {
        Text(text.uppercased())
            .gymFont(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch style {
        case .system:
            return .gymWhite
        case .region:
            return .gymMuted
        case .warmUp:
            return .gymAmber
        case .dropSet:
            return .gymRed
        case .failure:
            return .gymRed
        case .pr:
            return .gymLime
        case .custom:
            return customColor ?? .gymLime
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        BadgeLabel(text: "Chest", style: .region)
        BadgeLabel(text: "Back", style: .region)
        BadgeLabel(text: "Warm Up", style: .warmUp)
        BadgeLabel(text: "Drop Set", style: .dropSet)
        BadgeLabel(text: "PR", style: .pr)
        BadgeLabel(text: "Custom", style: .custom, customColor: .blue)
    }
    .padding()
    .background(Color.gymBlack)
}
