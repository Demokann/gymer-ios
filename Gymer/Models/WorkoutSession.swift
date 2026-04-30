import Foundation
import SwiftData

@Model
class WorkoutSession {
    var id: UUID
    var template: WorkoutTemplate?
    var templateName: String
    var startedAt: Date
    var finishedAt: Date?
    @Relationship(deleteRule: .cascade) var setLogs: [SetLog]
    var notes: String
    
    init(id: UUID = UUID(),
         template: WorkoutTemplate? = nil,
         templateName: String,
         startedAt: Date = Date(),
         finishedAt: Date? = nil,
         setLogs: [SetLog] = [],
         notes: String = "") {
        self.id = id
        self.template = template
        self.templateName = templateName
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.setLogs = setLogs
        self.notes = notes
    }
    
    var durationFormatted: String {
        guard let finishedAt = finishedAt else { return "0m" }
        let duration = Int(finishedAt.timeIntervalSince(startedAt))
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var totalVolumeKg: Double {
        setLogs.reduce(0) { total, log in
            if log.isFailure {
                return total
            } else {
                return total + (log.weightKg * Double(log.reps))
            }
        }
    }
    
    var exerciseCount: Int {
        Set(setLogs.map { $0.exerciseName }).count
    }
}
