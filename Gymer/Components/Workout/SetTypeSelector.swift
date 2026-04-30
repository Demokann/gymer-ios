// MARK: - SetTypeSelector
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: SetType, Color tokens, GymFont

import SwiftUI

struct SetTypeSelector: View {
    @Binding var selectedType: SetType
    let onSelect: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Set Type")
                .gymFont(.title)
                .foregroundColor(.gymWhite)
                .padding(.vertical, Spacing.lg)
            
            VStack(spacing: Spacing.md) {
                ForEach(SetType.allCases, id: \.self) { type in
                    Button {
                        selectedType = type
                        onSelect()
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Circle()
                                .fill(type.color)
                                .frame(width: 12, height: 12)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(type.rawValue)
                                    .gymFont(.body)
                                    .foregroundColor(.gymWhite)
                                
                                Text(description(for: type))
                                    .gymFont(.caption)
                                    .foregroundColor(.gymMuted)
                            }
                            
                            Spacer()
                            
                            if selectedType == type {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.gymLime)
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .padding(.all, Spacing.lg)
                        .background(Color.gymCard)
                        .cornerRadius(Radius.medium)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.medium)
                                .stroke(selectedType == type ? Color.gymLime : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.gymBlack)
    }
    
    private func description(for type: SetType) -> String {
        switch type {
        case .regular: return "Standard set for volume and strength"
        case .warmUp:  return "Light sets to prepare for working sets"
        case .dropSet: return "Reduce weight after failure to extend set"
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var selectedType: SetType = .regular
        var body: some View {
            SetTypeSelector(selectedType: $selectedType) {
                print("Selected: \(selectedType)")
            }
        }
    }
    return PreviewWrapper()
}
