// MARK: - DataService
// Owner: Backend Dev Agent
// Last Modified: 28.04.2026
// Depends on: SwiftData Models

import Foundation
import SwiftData

@MainActor
class DataService {
    static let shared = DataService()
    
    private init() {}
    
    func saveSession(_ session: WorkoutSession, context: ModelContext) {
        do {
            context.insert(session)
            try context.save()
        } catch {
            print("❌ Error saving workout session: \(error)")
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate, context: ModelContext) {
        do {
            context.delete(template)
            try context.save()
        } catch {
            print("❌ Error deleting template: \(error)")
        }
    }
    
    func personalRecord(for exercise: Exercise, context: ModelContext) -> SetLog? {
        let exerciseName = exercise.name
        let descriptor = FetchDescriptor<SetLog>(
            predicate: #Predicate { $0.exerciseName == exerciseName },
            sortBy: [SortDescriptor(\.weightKg, order: .reverse), SortDescriptor(\.reps, order: .reverse)]
        )
        
        do {
            let logs = try context.fetch(descriptor)
            return logs.first
        } catch {
            print("❌ Error fetching personal record: \(error)")
            return nil
        }
    }
    
    func saveExercise(_ exercise: Exercise, context: ModelContext) {
        do {
            context.insert(exercise)
            try context.save()
        } catch {
            print("❌ Error saving exercise: \(error)")
        }
    }
}
