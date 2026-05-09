// MARK: - GymerApp
// Owner: Backend Dev Agent
// Last Modified: 05.05.2026
// Depends on: AppRouter, WorkoutTemplate, ExerciseSlot, WorkoutSession, SetLog, Exercise

import SwiftUI
import SwiftData

@main
struct GymerApp: App {
    @State private var timerService = TimerService()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .modelContainer(for: [
                    WorkoutTemplate.self,
                    ExerciseSlot.self,
                    WorkoutSession.self,
                    SetLog.self,
                    Exercise.self
                ])
                .environment(timerService)
                .preferredColorScheme(.dark)
        }
    }
}
