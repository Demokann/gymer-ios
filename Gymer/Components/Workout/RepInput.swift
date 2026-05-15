// MARK: - RepInput
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: Color tokens, GymFont, Spacing

import SwiftUI

struct RepInput: View {
    @Binding var reps: Int
    @Binding var isFailure: Bool
    let label: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gymMuted)
            
            HStack(spacing: 4) {
                Button {
                    adjustReps(by: -1)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 28, height: 28)
                        .background(Color.gymSurface)
                        .clipShape(Circle())
                }
                
                ZStack {
                    TextField("0", value: $reps, format: .number)
                        .keyboardType(.numberPad)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(isFailure ? .gymMuted : .gymWhite)
                        .multilineTextAlignment(.center)
                        .frame(width: 44)
                        .padding(.vertical, 4)
                        .background(Color.gymCard)
                        .cornerRadius(Radius.small)
                        .opacity(isFailure ? 0.3 : 1.0)
                        .disabled(isFailure)
                    
                    if isFailure {
                        Text("FAIL")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.gymRed)
                    }
                }
                
                Button {
                    adjustReps(by: 1)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gymLime)
                        .frame(width: 28, height: 28)
                        .background(Color.gymSurface)
                        .clipShape(Circle())
                }
                
                Button {
                    isFailure.toggle()
                    if isFailure {
                        reps = 0
                    }
                } label: {
                    Text("F")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isFailure ? .gymWhite : .gymRed)
                        .frame(width: 28, height: 28)
                        .background(isFailure ? Color.gymRed : Color.clear)
                        .cornerRadius(Radius.small)
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.small)
                                .stroke(Color.gymRed, lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private func adjustReps(by delta: Int) {
        if isFailure { isFailure = false }
        reps = max(0, reps + delta)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var reps: Int = 10
        @State var isFailure: Bool = false
        var body: some View {
            ZStack {
                Color.gymBlack.ignoresSafeArea()
                RepInput(reps: $reps, isFailure: $isFailure, label: "REPS")
            }
        }
    }
    return PreviewWrapper()
}
