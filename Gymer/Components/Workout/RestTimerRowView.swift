// MARK: - RestTimerRowView
// Owner: UI Designer Agent
// Last Modified: 2026-05-15
// Dependencies: Formatters, Color tokens, Spacing

import SwiftUI

struct RestTimerRowView: View {
    @Binding var seconds: Int

    @State private var isExpanded = false
    @State private var isEditing = false
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            // Header — entire row is tappable to expand/collapse
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Spacing.md) {
                    Text("Rest")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gymMuted)
                        .textCase(.uppercase)

                    Text(Formatters.formatRestTimer(seconds))
                        .font(.system(.caption, design: .monospaced))
                        .fontWeight(.medium)
                        .foregroundColor(.gymWhite)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gymMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                }
                .contentShape(Rectangle())
                .padding(.horizontal, Spacing.xs)
                .padding(.vertical, Spacing.sm)
            }
            .buttonStyle(.plain)

            if isExpanded {
                HStack(spacing: Spacing.md) {
                    Button {
                        seconds = max(15, seconds - 15)
                    } label: {
                        Text("− 15s")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gymLime)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 6)
                            .background(Color.gymCard)
                            .cornerRadius(Radius.small)
                    }

                    Spacer()

                    if isEditing {
                        HStack(spacing: Spacing.xs) {
                            TextField("", text: $inputText)
                                .keyboardType(.numberPad)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.gymLime)
                                .multilineTextAlignment(.center)
                                .frame(width: 56)
                                .padding(.vertical, 4)
                                .background(Color.gymCard)
                                .cornerRadius(Radius.small)
                                .onSubmit { commitEdit() }

                            Button("Set") {
                                commitEdit()
                            }
                            .font(.caption.bold())
                            .foregroundColor(.gymLime)
                        }
                    } else {
                        Button {
                            inputText = "\(seconds)"
                            isEditing = true
                        } label: {
                            Text(Formatters.formatRestTimer(seconds))
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)
                                .foregroundColor(.gymWhite)
                                .underline(color: Color.gymMuted.opacity(0.6))
                                .frame(minWidth: 44, alignment: .center)
                        }
                    }

                    Spacer()

                    Button {
                        seconds = min(300, seconds + 15)
                    } label: {
                        Text("+ 15s")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.gymLime)
                            .padding(.horizontal, Spacing.sm)
                            .padding(.vertical, 6)
                            .background(Color.gymCard)
                            .cornerRadius(Radius.small)
                    }
                }
                .padding(.horizontal, Spacing.xs)
                .padding(.bottom, Spacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.gymSurface)
        .cornerRadius(Radius.small)
    }

    private func commitEdit() {
        if let typed = Int(inputText) {
            seconds = max(15, min(300, typed))
        }
        isEditing = false
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var seconds = 90
        var body: some View {
            ZStack {
                Color.gymBlack.ignoresSafeArea()
                RestTimerRowView(seconds: $seconds)
                    .padding()
            }
        }
    }
    return PreviewWrapper()
}
