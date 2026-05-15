// MARK: - RestTimerOverlay
// Owner: UI Designer Agent
// Last Modified: 2026-05-15
// Dependencies: TimerService, Color tokens, GymFont, Spacing, Formatters

import SwiftUI

struct RestTimerOverlay: View {
    @Environment(TimerService.self) private var timerService
    @Environment(\.dismiss) private var dismiss

    @State private var isEditingTime = false
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Header
            HStack {
                Text("REST")
                    .gymFont(.title)
                    .foregroundColor(.gymWhite)

                Spacer()

                Button {
                    timerService.stop()
                    dismiss()
                } label: {
                    Text("Skip →")
                        .gymFont(.body)
                        .foregroundColor(.gymLime)
                }
            }
            .padding(.horizontal, Spacing.xl)
            .padding(.top, Spacing.lg)

            // Compact Timer Ring
            ZStack {
                Circle()
                    .stroke(Color.gymSurface, lineWidth: 12)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: timerService.progress)
                    .stroke(
                        Color.gymLime,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1.0), value: timerService.secondsRemaining)

                if isEditingTime {
                    VStack(spacing: Spacing.xs) {
                        TextField("", text: $inputText)
                            .keyboardType(.numberPad)
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundColor(.gymLime)
                            .multilineTextAlignment(.center)
                            .frame(width: 80)
                            .onSubmit { commitTimeEdit() }

                        Button("Set") {
                            commitTimeEdit()
                        }
                        .font(.caption.bold())
                        .foregroundColor(.gymLime)
                    }
                } else {
                    VStack(spacing: 0) {
                        Text(Formatters.formatRestTimer(timerService.secondsRemaining))
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundColor(.gymWhite)
                            .underline(color: Color.gymMuted.opacity(0.5))

                        Text("TAP TO EDIT")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gymMuted)
                    }
                    .onTapGesture {
                        inputText = "\(timerService.secondsRemaining)"
                        isEditingTime = true
                    }
                }
            }

            // Adjust Buttons
            HStack(spacing: Spacing.xl) {
                Button {
                    timerService.adjust(by: -15)
                } label: {
                    Text("−15s")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gymWhite)
                        .frame(width: 64, height: 36)
                        .background(Color.gymCard)
                        .cornerRadius(Radius.small)
                }

                Button {
                    timerService.adjust(by: 15)
                } label: {
                    Text("+15s")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gymWhite)
                        .frame(width: 64, height: 36)
                        .background(Color.gymCard)
                        .cornerRadius(Radius.small)
                }
            }

            Spacer()
        }
        .background(Color.gymBlack)
        .onChange(of: timerService.secondsRemaining) { _, newValue in
            if newValue == 0 {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    dismiss()
                }
            }
        }
    }

    private func commitTimeEdit() {
        if let typed = Int(inputText), typed > 0 {
            let clamped = max(1, min(3600, typed))
            timerService.adjust(by: clamped - timerService.secondsRemaining)
            timerService.totalSeconds = clamped
        }
        isEditingTime = false
    }
}

#Preview {
    let timerService = TimerService()
    return RestTimerOverlay()
        .environment(timerService)
        .onAppear {
            timerService.start(seconds: 90) {}
        }
}
