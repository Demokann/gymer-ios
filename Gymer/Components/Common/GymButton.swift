// MARK: - GymButton
// Owner: UI Designer Agent
// Last Modified: 28.04.2026
// Dependencies: DesignSystem/Colors, DesignSystem/Spacing

import SwiftUI

struct GymButton: View {
    enum Style {
        case primary
        case secondary
        case ghost
    }
    
    let title: String
    let icon: String?
    let style: Style
    let action: () -> Void
    
    init(_ title: String, 
         icon: String? = nil, 
         style: Style = .primary, 
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .gymFont(.body)
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(backgroundView)
            .foregroundColor(foregroundColor)
            .overlay(borderView)
            .cornerRadius(Radius.pill)
        }
        .buttonStyle(GymButtonStyle())
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            Color.gymLime
        case .secondary, .ghost:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .black
        case .secondary:
            return .gymLime
        case .ghost:
            return .gymMuted
        }
    }
    
    @ViewBuilder
    private var borderView: some View {
        if style == .secondary {
            RoundedRectangle(cornerRadius: Radius.pill)
                .stroke(Color.gymLime, lineWidth: 1)
        }
    }
}

struct GymButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        GymButton("Primary Button") {}
        GymButton("Secondary Button", style: .secondary) {}
        GymButton("Ghost Button", style: .ghost) {}
        GymButton("Button with Icon", icon: "plus") {}
    }
    .padding()
    .background(Color.gymBlack)
}
