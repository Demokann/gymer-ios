import Foundation
import SwiftData

@Model
class ExerciseSlot {
    var id: UUID
    var exercise: Exercise
    var order: Int
    var targetSets: Int
    var targetReps: Int
    var targetWeightKg: Double
    var defaultRestSeconds: Int
    var notes: String
    
    init(id: UUID = UUID(),
         exercise: Exercise,
         order: Int,
         targetSets: Int = 3,
         targetReps: Int = 10,
         targetWeightKg: Double = 0,
         defaultRestSeconds: Int = 90,
         notes: String = "") {
        self.id = id
        self.exercise = exercise
        self.order = order
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeightKg = targetWeightKg
        self.defaultRestSeconds = defaultRestSeconds
        self.notes = notes
    }
}
