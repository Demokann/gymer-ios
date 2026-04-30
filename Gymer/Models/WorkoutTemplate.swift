import Foundation
import SwiftData

@Model
class WorkoutTemplate {
    var id: UUID
    var name: String
    var emoji: String
    var colorHex: String
    @Relationship(deleteRule: .cascade) var slots: [ExerciseSlot]
    var createdAt: Date
    var lastUsedAt: Date?
    var sessionCount: Int
    
    init(id: UUID = UUID(),
         name: String,
         emoji: String = "💪",
         colorHex: String = "#C6FF00",
         slots: [ExerciseSlot] = [],
         createdAt: Date = Date(),
         sessionCount: Int = 0) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.slots = slots
        self.createdAt = createdAt
        self.sessionCount = sessionCount
    }
}
