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
            let slots = template.slots  // explicit access triggers SwiftData relationship fault
            if slots.isEmpty {
                print("⚠️ Template '\(template.name)' has no slots — relationship may not have loaded")
            }
            let lastSession = dataService.lastSession(for: template, context: modelContext)
            self.exerciseStates = slots.sorted(by: { $0.order < $1.order }).compactMap { slot in
                let setCount = max(1, slot.targetSets)
                let previousLogs = (lastSession?.setLogs ?? [])
                    .filter { $0.exerciseName == slot.exercise.name }
                    .sorted { $0.setIndex < $1.setIndex }
                let initialSets = (0..<setCount).map { i in
                    if i < previousLogs.count {
                        let log = previousLogs[i]
                        return SetState(weightKg: log.weightKg, reps: log.reps, type: log.setType, isFailure: log.isFailure)
                    }
                    return SetState(weightKg: slot.targetWeightKg, reps: slot.targetReps)
                }
                return ExerciseState(exercise: slot.exercise, sets: initialSets, defaultRestSeconds: slot.defaultRestSeconds)
            }
        }
        
        startTimer()
    }
    
    // MARK: - Timer Logic
    private func startTimer() {
        timerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                if !Task.isCancelled {
                    self.elapsedTime = Int(Date().timeIntervalSince(self.startTime))
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
        
        if setState.isCompleted {
            // Uncomplete
            setState.isCompleted = false
            setState.completedAt = nil
            
            // Find and remove the log from session
            if let session = workoutSession {
                session.setLogs.removeAll { log in
                    log.exerciseName == exerciseState.exercise.name && 
                    log.setIndex == setIndex + 1 &&
                    Calendar.current.isDate(log.completedAt, inSameDayAs: startTime)
                }
            }
        } else {
            // Complete
            setState.isCompleted = true
            setState.completedAt = Date()
            
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
                log.isPersonalRecord = !setState.isFailure
            }
            
            workoutSession?.setLogs.append(log)
            
            // Start rest timer
            timerService.start(seconds: exerciseState.defaultRestSeconds) { }
        }
        
        exerciseState.sets[setIndex] = setState
        exerciseStates[exerciseIndex] = exerciseState
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving set log: \(error)")
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
    
    func removeSet(setId: UUID, exerciseId: UUID) {
        guard let exIdx = exerciseStates.firstIndex(where: { $0.id == exerciseId }),
              let setIdx = exerciseStates[exIdx].sets.firstIndex(where: { $0.id == setId })
        else { return }
        exerciseStates[exIdx].sets.remove(at: setIdx)
    }

    func removeExercise(id: UUID) {
        guard let index = exerciseStates.firstIndex(where: { $0.id == id }) else { return }
        let exerciseName = exerciseStates[index].exercise.name

        if let session = workoutSession {
            let toDelete = session.setLogs.filter { $0.exerciseName == exerciseName }
            toDelete.forEach { modelContext.delete($0) }
            session.setLogs.removeAll { $0.exerciseName == exerciseName }
        }

        exerciseStates.remove(at: index)

        do {
            try modelContext.save()
        } catch {
            print("❌ Error removing exercise: \(error)")
        }
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

    func adjustRestSeconds(by delta: Int, for exerciseIndex: Int) {
        guard exerciseIndex < exerciseStates.count else { return }
        let current = exerciseStates[exerciseIndex].defaultRestSeconds
        exerciseStates[exerciseIndex].defaultRestSeconds = max(15, min(300, current + delta))
    }

    func setRestSeconds(_ seconds: Int, for exerciseIndex: Int) {
        guard exerciseIndex < exerciseStates.count else { return }
        exerciseStates[exerciseIndex].defaultRestSeconds = max(15, min(300, seconds))
    }
    
    func finishWorkout(notes: String = "") {
        timerTask?.cancel()
        timerTask = nil

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
