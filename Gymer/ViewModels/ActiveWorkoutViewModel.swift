// MARK: - ActiveWorkoutViewModel
// Owner: Backend Dev Agent
// Last Modified: 03.05.2026
// Depends on: WorkoutSession, WorkoutTemplate, SetLog, Exercise, TimerService, DataService

import SwiftUI
import SwiftData
import Observation

struct SetState: Identifiable {
    let id = UUID()
    var weightKg: Double
    var reps: Int
    var type: SetType = .regular
    var isFailure: Bool = false
    var isCompleted: Bool = false
    var completedAt: Date?
}

struct ExerciseState: Identifiable {
    let id = UUID()
    let exercise: Exercise
    var sets: [SetState]
    var defaultRestSeconds: Int
}

@Observable @MainActor
class ActiveWorkoutViewModel {
    // MARK: - Published State
    var template: WorkoutTemplate?
    var exerciseStates: [ExerciseState] = []
    var elapsedTime: Int = 0
    var isFinished = false
    var workoutSession: WorkoutSession?
    
    // MARK: - Properties
    private let modelContext: ModelContext
    private let timerService: TimerService
    private let dataService = DataService.shared
    private var timerTask: Task<Void, Never>?
    private var startTime: Date
    
    // MARK: - Initialization
    init(modelContext: ModelContext, timerService: TimerService, template: WorkoutTemplate? = nil) {
        self.modelContext = modelContext
        self.timerService = timerService
        self.template = template
        self.startTime = Date()
        
        // Create the session immediately to associate logs
        let session = WorkoutSession(
            template: template,
            templateName: template?.name ?? "Empty Workout",
            startedAt: startTime
        )
        modelContext.insert(session)
        self.workoutSession = session
        
        if let template = template {
            self.exerciseStates = template.slots.sorted(by: { $0.order < $1.order }).map { slot in
                let initialSets = (1...slot.targetSets).map { _ in
                    SetState(weightKg: slot.targetWeightKg, reps: slot.targetReps)
                }
                return ExerciseState(exercise: slot.exercise, sets: initialSets, defaultRestSeconds: slot.defaultRestSeconds)
            }
        }
        
        startTimer()
    }
    
    // MARK: - Timer Logic
    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    elapsedTime = Int(Date().timeIntervalSince(startTime))
                }
            }
        }
    }
    
    // MARK: - Intents
    func completeSet(exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exerciseStates.count, 
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        
        var exerciseState = exerciseStates[exerciseIndex]
        var setState = exerciseState.sets[setIndex]
        
        guard !setState.isCompleted else { return }
        
        setState.isCompleted = true
        setState.completedAt = Date()
        exerciseState.sets[setIndex] = setState
        exerciseStates[exerciseIndex] = exerciseState
        
        // Log to SwiftData immediately
        let log = SetLog(
            exercise: exerciseState.exercise,
            exerciseName: exerciseState.exercise.name,
            setIndex: setIndex + 1,
            setType: setState.type,
            weightKg: setState.weightKg,
            reps: setState.reps,
            isFailure: setState.isFailure,
            completedAt: setState.completedAt ?? Date()
        )
        
        // Check for PR
        if let best = dataService.personalRecord(for: exerciseState.exercise, context: modelContext) {
            let currentVolume = setState.isFailure ? 0 : setState.weightKg * Double(setState.reps)
            let bestVolume = best.isFailure ? 0 : best.weightKg * Double(best.reps)
            if currentVolume > bestVolume {
                log.isPersonalRecord = true
            }
        } else {
            // First time doing this exercise
            log.isPersonalRecord = !setState.isFailure
        }
        
        // Associate with session
        workoutSession?.setLogs.append(log)
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving set log: \(error)")
        }
        
        // Start rest timer
        timerService.start(seconds: exerciseState.defaultRestSeconds) {
            // Optional completion handler
        }
    }
    
    func addSet(to exerciseIndex: Int) {
        guard exerciseIndex < exerciseStates.count else { return }
        let lastSet = exerciseStates[exerciseIndex].sets.last
        let newSet = SetState(
            weightKg: lastSet?.weightKg ?? 0,
            reps: lastSet?.reps ?? 10,
            type: .regular
        )
        exerciseStates[exerciseIndex].sets.append(newSet)
    }
    
    func removeSet(from exerciseIndex: Int, at setIndex: Int) {
        guard exerciseIndex < exerciseStates.count,
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        exerciseStates[exerciseIndex].sets.remove(at: setIndex)
    }
    
    func addExercise(_ exercise: Exercise) {
        let newState = ExerciseState(
            exercise: exercise,
            sets: [SetState(weightKg: 0, reps: 10)],
            defaultRestSeconds: 90
        )
        exerciseStates.append(newState)
    }
    
    func updateSetType(_ type: SetType, for exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exerciseStates.count,
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        exerciseStates[exerciseIndex].sets[setIndex].type = type
    }
    
    func updateWeight(_ kg: Double, for exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exerciseStates.count,
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        exerciseStates[exerciseIndex].sets[setIndex].weightKg = kg
    }
    
    func updateReps(_ reps: Int, for exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exerciseStates.count,
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        exerciseStates[exerciseIndex].sets[setIndex].reps = reps
    }
    
    func toggleFailure(for exerciseIndex: Int, setIndex: Int) {
        guard exerciseIndex < exerciseStates.count,
              setIndex < exerciseStates[exerciseIndex].sets.count else { return }
        exerciseStates[exerciseIndex].sets[setIndex].isFailure.toggle()
    }
    
    func finishWorkout(notes: String = "") {
        timerTask?.cancel()
        
        if let session = workoutSession {
            session.finishedAt = Date()
            session.notes = notes
            
            do {
                try modelContext.save()
                isFinished = true
            } catch {
                print("❌ Error finishing workout: \(error)")
            }
        }
    }
}
