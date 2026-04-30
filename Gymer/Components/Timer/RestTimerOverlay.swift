// MARK: - RestTimerOverlay
// Owner: UI Designer Agent
// Last Modified: 2026-04-30
// Dependencies: TimerService, Color tokens, GymFont, Spacing, Formatters

import SwiftUI

struct RestTimerOverlay: View {
    @Environment(TimerService.self) private var timerService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.gymBlack.ignoresSafeArea()
            
            VStack(spacing: Spacing.xxl) {
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
                
                Spacer()
                
                // Timer Ring
                ZStack {
                    Circle()
                        .stroke(Color.gymSurface, lineWidth: 20)
                        .frame(width: 250, height: 250)
                    
                    Circle()
                        .trim(from: 0, to: timerService.progress)
                        .stroke(
                            Color.gymLime,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1.0), value: timerService.secondsRemaining)
                    
                    VStack(spacing: 0) {
                        Text(Formatters.formatRestTimer(timerService.secondsRemaining))
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(.gymWhite)
                        
                        Text("REMAINING")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                    }
                }
                
                Spacer()
                
                // Adjust Buttons
                HStack(spacing: Spacing.xl) {
                    Button {
                        timerService.adjust(by: -15)
                    } label: {
                        VStack {
                            Image(systemName: "minus")
                            Text("15s")
                                .gymFont(.caption)
                        }
                        .foregroundColor(.gymWhite)
                        .frame(width: 80, height: 80)
                        .background(Color.gymCard)
                        .clipShape(Circle())
                    }
                    
                    Button {
                        timerService.adjust(by: 15)
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                            Text("15s")
                                .gymFont(.caption)
                        }
                        .foregroundColor(.gymWhite)
                        .frame(width: 80, height: 80)
                        .background(Color.gymCard)
                        .clipShape(Circle())
                    }
                }
                
                Spacer()
                
                // Done Button
                Button {
                    dismiss()
                } label: {
                    Text("Minimize")
                        .gymFont(.body)
                        .foregroundColor(.gymMuted)
                }
                .padding(.bottom, Spacing.xl)
            }
        }
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
