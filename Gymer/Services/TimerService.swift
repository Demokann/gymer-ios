// MARK: - TimerService
// Owner: Backend Dev Agent
// Last Modified: 28.04.2026
// Depends on: None

import SwiftUI
import Observation

@MainActor
@Observable
class TimerService {
    static let shared = TimerService()
    
    var secondsRemaining: Int = 0
    var isRunning: Bool = false
    var totalSeconds: Int = 0
    
    private var timerTask: Task<Void, Never>?
    private var backgroundedAt: Date?
    
    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(secondsRemaining) / Double(totalSeconds)
    }
    
    func start(seconds: Int, onComplete: @escaping () -> Void) {
        stop()
        totalSeconds = seconds
        secondsRemaining = seconds
        isRunning = true
        timerTask = makeTimerTask(onComplete: onComplete)
    }

    func pause() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
    }

    func resume(onComplete: @escaping () -> Void) {
        guard !isRunning && secondsRemaining > 0 else { return }
        isRunning = true
        timerTask = makeTimerTask(onComplete: onComplete)
    }

    func stop() {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        secondsRemaining = 0
    }

    private func makeTimerTask(onComplete: @escaping () -> Void) -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else { return }
            while self.secondsRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    self.secondsRemaining -= 1
                }
            }
            if !Task.isCancelled {
                self.isRunning = false
                onComplete()
            }
        }
    }

    func adjust(by delta: Int) {
        secondsRemaining = max(0, min(3600, secondsRemaining + delta))
    }
    
    func handleBackground() {
        backgroundedAt = Date()
    }
    
    func handleForeground(onComplete: @escaping () -> Void) {
        guard let backgroundedAt = backgroundedAt, isRunning else { return }
        
        let timeInBackground = Int(Date().timeIntervalSince(backgroundedAt))
        secondsRemaining = max(0, secondsRemaining - timeInBackground)
        
        if secondsRemaining == 0 {
            isRunning = false
            onComplete()
        }
        
        self.backgroundedAt = nil
    }
}
