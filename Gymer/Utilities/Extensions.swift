// MARK: - Extensions
// Owner: Backend Dev Agent
// Last Modified: 28.04.2026
// Depends on: None

import SwiftUI

extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
