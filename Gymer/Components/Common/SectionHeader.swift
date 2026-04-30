// MARK: - SectionHeader
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: GymFont, Color tokens

import SwiftUI

struct SectionHeader: View {
    let title: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .gymFont(.title)
                .foregroundColor(.gymWhite)
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .gymFont(.caption)
                        .foregroundColor(.gymLime)
                        .padding(.vertical, Spacing.xs)
                        .padding(.horizontal, Spacing.sm)
                }
                .background(Color.gymLime.opacity(0.1))
                .cornerRadius(Radius.small)
            }
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    ZStack {
        Color.gymBlack.ignoresSafeArea()
        VStack {
            SectionHeader(title: "My Templates", actionTitle: "See All") {
                print("Action tapped")
            }
            SectionHeader(title: "Recent Workouts")
            Spacer()
        }
    }
}
