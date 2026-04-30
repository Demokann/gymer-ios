// MARK: - SetRowView
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: SetType, WeightInput, RepInput, BadgeLabel, SetTypeSelector

import SwiftUI

struct SetRowView: View {
    @Binding var setType: SetType
    @Binding var weightKg: Double
    @Binding var reps: Int
    @Binding var isFailure: Bool
    @Binding var isCompleted: Bool
    
    let setIndex: Int
    let onComplete: () -> Void
    
    @State private var showingTypeSelector = false
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Set Index & Type Badge
            VStack(alignment: .leading, spacing: 4) {
                Text("SET \(setIndex)")
                    .gymFont(.caption)
                    .foregroundColor(.gymMuted)
                
                Button {
                    showingTypeSelector = true
                } label: {
                    if setType == .regular {
                        Circle()
                            .stroke(Color.gymBorder, lineWidth: 1)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text("\(setIndex)")
                                    .gymFont(.caption)
                                    .foregroundColor(.gymWhite)
                            )
                    } else {
                        Text(setType.abbreviation)
                            .gymFont(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(setType.color)
                            .frame(width: 24, height: 24)
                            .background(setType.color.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .frame(width: 40)
            
            // Weight Input
            WeightInput(weight: $weightKg, label: "WEIGHT")
                .disabled(isCompleted)
                .opacity(isCompleted ? 0.6 : 1.0)
            
            Spacer(minLength: 0)
            
            // Rep Input
            RepInput(reps: $reps, isFailure: $isFailure, label: "REPS")
                .disabled(isCompleted)
                .opacity(isCompleted ? 0.6 : 1.0)
            
            Spacer(minLength: 0)
            
            // Completion Button
            Button {
                withAnimation(.spring) {
                    isCompleted.toggle()
                    if isCompleted {
                        onComplete()
                    }
                }
            } label: {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 28))
                    .foregroundColor(isCompleted ? .gymLime : .gymBorder)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.vertical, Spacing.sm)
        .padding(.horizontal, Spacing.md)
        .background(isCompleted ? Color.gymLime.opacity(0.05) : Color.clear)
        .cornerRadius(Radius.medium)
        .sheet(isPresented: $showingTypeSelector) {
            SetTypeSelector(selectedType: $setType) {
                showingTypeSelector = false
            }
            .presentationDetents([.height(350)])
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var setType: SetType = .regular
        @State var weight: Double = 80.0
        @State var reps: Int = 10
        @State var isFailure: Bool = false
        @State var isCompleted: Bool = false
        
        var body: some View {
            ZStack {
                Color.gymBlack.ignoresSafeArea()
                VStack(spacing: 20) {
                    SetRowView(
                        setType: $setType,
                        weightKg: $weight,
                        reps: $reps,
                        isFailure: $isFailure,
                        isCompleted: $isCompleted,
                        setIndex: 1,
                        onComplete: { print("Set completed!") }
                    )
                    
                    SetRowView(
                        setType: .constant(.warmUp),
                        weightKg: .constant(40.0),
                        reps: .constant(15),
                        isFailure: .constant(false),
                        isCompleted: .constant(true),
                        setIndex: 2,
                        onComplete: {}
                    )
                    
                    SetRowView(
                        setType: .constant(.dropSet),
                        weightKg: .constant(60.0),
                        reps: .constant(8),
                        isFailure: .constant(true),
                        isCompleted: .constant(false),
                        setIndex: 3,
                        onComplete: {}
                    )
                }
                .padding()
            }
        }
    }
    return PreviewWrapper()
}
