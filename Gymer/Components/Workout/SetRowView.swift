// MARK: - SetRowView
// Owner: UI Designer Agent
// Last Modified: 2026-05-15
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
    var onDelete: (() -> Void)? = nil

    @State private var showingTypeSelector = false
    @State private var swipeOffset: CGFloat = 0

    private let deleteRevealWidth: CGFloat = 68

    var body: some View {
        ZStack(alignment: .trailing) {
            if onDelete != nil {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        swipeOffset = 0
                    }
                    onDelete?()
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .frame(width: deleteRevealWidth)
                        .frame(maxHeight: .infinity)
                        .background(Color.gymRed)
                        .cornerRadius(Radius.medium)
                }
                .opacity(swipeOffset < -8 ? 1 : 0)
            }

            rowContent
                .offset(x: swipeOffset)
                .gesture(
                    onDelete != nil
                        ? DragGesture(minimumDistance: 15, coordinateSpace: .local)
                            .onChanged { value in
                                let x = value.translation.width
                                if x < 0 {
                                    swipeOffset = max(-deleteRevealWidth, x)
                                } else if swipeOffset < 0 {
                                    swipeOffset = min(0, swipeOffset + x)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    swipeOffset = swipeOffset < -(deleteRevealWidth / 2)
                                        ? -deleteRevealWidth
                                        : 0
                                }
                            }
                        : nil
                )
        }
        .clipped()
        .sheet(isPresented: $showingTypeSelector) {
            SetTypeSelector(selectedType: $setType) {
                showingTypeSelector = false
            }
            .presentationDetents([.height(350)])
        }
    }

    private var rowContent: some View {
        HStack(spacing: 8) {
            // Set Index & Type Badge
            VStack(alignment: .leading, spacing: 2) {
                Text("SET \(setIndex)")
                    .font(.system(size: 8, weight: .bold))
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
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.gymWhite)
                            )
                    } else {
                        Text(setType.abbreviation)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(setType.color)
                            .frame(width: 24, height: 24)
                            .background(setType.color.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
            }
            .frame(width: 32)

            // Weight Input
            WeightInput(weight: $weightKg, label: "WEIGHT")
                .disabled(isCompleted)
                .opacity(isCompleted ? 0.6 : 1.0)

            // Rep Input
            RepInput(reps: $reps, isFailure: $isFailure, label: "REPS")
                .disabled(isCompleted)
                .opacity(isCompleted ? 0.6 : 1.0)

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
                    .font(.system(size: 24))
                    .foregroundColor(isCompleted ? .gymLime : .gymBorder)
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(isCompleted ? Color.gymLime.opacity(0.05) : Color.clear)
        .cornerRadius(Radius.medium)
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
                        onComplete: { print("Set completed!") },
                        onDelete: { print("Deleted!") }
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
                }
                .padding()
            }
        }
    }
    return PreviewWrapper()
}
