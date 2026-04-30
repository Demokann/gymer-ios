import Foundation
import SwiftData

@Model
class SetLog {
    var id: UUID
    var exercise: Exercise?
    var exerciseName: String
    var setIndex: Int
    var setType: SetType
    var weightKg: Double
    var reps: Int
    var isFailure: Bool
    var isPersonalRecord: Bool
    var completedAt: Date
    var restSeconds: Int
    
    init(id: UUID = UUID(),
         exercise: Exercise? = nil,
         exerciseName: String,
         setIndex: Int,
         setType: SetType = .regular,
         weightKg: Double,
         reps: Int,
         isFailure: Bool = false,
         isPersonalRecord: Bool = false,
         completedAt: Date = Date(),
         restSeconds: Int = 0) {
        self.id = id
        self.exercise = exercise
        self.exerciseName = exerciseName
        self.setIndex = setIndex
        self.setType = setType
        self.weightKg = weightKg
        self.reps = reps
        self.isFailure = isFailure
        self.isPersonalRecord = isPersonalRecord
        self.completedAt = completedAt
        self.restSeconds = restSeconds
    }
}
