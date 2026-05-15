// MARK: - WeightInput
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: Color tokens, GymFont, Spacing

import SwiftUI

struct WeightInput: View {
    @Binding var weight: Double
    let label: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gymMuted)
            
            HStack(spacing: 4) {
                Button {
                    adjustWeight(by: -2.5)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 28, height: 28)
                        .background(Color.gymSurface)
                        .clipShape(Circle())
                }
                
                TextField("0", value: $weight, format: .number)
                    .keyboardType(.decimalPad)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gymWhite)
                    .multilineTextAlignment(.center)
                    .frame(width: 54)
                    .padding(.vertical, 4)
                    .background(Color.gymCard)
                    .cornerRadius(Radius.small)
                
                Button {
                    adjustWeight(by: 2.5)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 28, height: 28)
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
