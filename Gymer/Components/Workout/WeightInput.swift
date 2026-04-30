// MARK: - WeightInput
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: Color tokens, GymFont, Spacing

import SwiftUI

struct WeightInput: View {
    @Binding var weight: Double
    let label: String
    
    var body: some View {
        VStack(alignment: .center, spacing: Spacing.xs) {
            Text(label)
                .gymFont(.caption)
                .foregroundColor(.gymMuted)
            
            HStack(spacing: Spacing.sm) {
                Button {
                    adjustWeight(by: -2.5)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 32, height: 32)
                        .background(Color.gymSurface)
                        .clipShape(Circle())
                }
                
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .gymFont(.mono)
                    .foregroundColor(.gymWhite)
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.gymCard)
                    .cornerRadius(Radius.small)
                
                Button {
                    adjustWeight(by: 2.5)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 32, height: 32)
                        .background(Color.gymSurface)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private func adjustWeight(by delta: Double) {
        weight = max(0, weight + delta)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var weight: Double = 60.0
        var body: some View {
            ZStack {
                Color.gymBlack.ignoresSafeArea()
                WeightInput(weight: $weight, label: "WEIGHT (KG)")
            }
        }
    }
    return PreviewWrapper()
}
