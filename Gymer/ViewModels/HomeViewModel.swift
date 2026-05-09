// MARK: - HomeViewModel
// Owner: Backend Dev Agent
// Last Modified: 03.05.2026
// Depends on: WorkoutSession, SetLog, BodyRegion

import SwiftUI
import SwiftData

@Observable @MainActor
class HomeViewModel {
    // MARK: - Published State
    var totalWorkouts: Int = 0
    var thisMonthWorkouts: Int = 0
    var bestStreak: Int = 0
    var recentPRs: [SetLog] = []
    var bodyRegionDistribution: [(region: BodyRegion, count: Int)] = []
    
    // MARK: - Properties
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Intents
    func fetchStats() {
        let sessionDescriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.finishedAt != nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        
        do {
            let sessions = try modelContext.fetch(sessionDescriptor)
            totalWorkouts = sessions.count
            
            let calendar = Calendar.current
            let now = Date()
            thisMonthWorkouts = sessions.filter { calendar.isDate($0.startedAt, equalTo: now, toGranularity: .month) }.count
            
            // Streak calculation
            bestStreak = calculateStreak(sessions: sessions)
            
            // Recent PRs
            fetchRecentPRs()
            
            // Body region distribution
            calculateDistribution(sessions: sessions)
            
        } catch {
            print("❌ Error fetching home stats: \(error)")
        }
    }
    
    private func calculateStreak(sessions: [WorkoutSession]) -> Int {
        guard !sessions.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        var currentStreak = 0
        var bestStreak = 0
        var lastDate: Date?
        
        // Ensure sessions are sorted by date ascending for streak calculation
        let sortedSessions = sessions.sorted(by: { $0.startedAt < $1.startedAt })
        let uniqueDays = Set(sortedSessions.map { calendar.startOfDay(for: $0.startedAt) }).sorted()
        
        for date in uniqueDays {
            if let last = lastDate {
                let diff = calendar.dateComponents([.day], from: last, to: date).day ?? 0
                if diff == 1 {
                    currentStreak += 1
                } else if diff > 1 {
                    bestStreak = max(bestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            lastDate = date
        }
        
        return max(bestStreak, currentStreak)
    }
    
    private func fetchRecentPRs() {
        let descriptor = FetchDescriptor<SetLog>(
            predicate: #Predicate { $0.isPersonalRecord == true },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        
        do {
            let allPRs = try modelContext.fetch(descriptor)
            recentPRs = Array(allPRs.prefix(5))
        } catch {
            print("❌ Error fetching recent PRs: \(error)")
        }
    }
    
    private func calculateDistribution(sessions: [WorkoutSession]) {
        var counts: [BodyRegion: Int] = [:]
        
        for session in sessions {
            for log in session.setLogs {
                if let exercise = log.exercise {
                    for region in exercise.bodyRegions {
                        counts[region, default: 0] += 1
                    }
                }
            }
        }
        
        bodyRegionDistribution = counts.map { (region: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
    }
}
