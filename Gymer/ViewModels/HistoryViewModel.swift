// MARK: - HistoryViewModel
// Owner: Backend Dev Agent
// Last Modified: 03.05.2026
// Depends on: WorkoutSession

import SwiftUI
import SwiftData

@Observable @MainActor
class HistoryViewModel {
    // MARK: - Published State
    var sessions: [WorkoutSession] = []
    var groupedSessions: [(month: String, sessions: [WorkoutSession])] = []
    var isLoading = false
    
    // MARK: - Properties
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Intents
    func fetchHistory() {
        isLoading = true
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.finishedAt != nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        
        do {
            sessions = try modelContext.fetch(descriptor)
            groupSessions()
            isLoading = false
        } catch {
            print("❌ Error fetching history: \(error)")
            isLoading = false
        }
    }
    
    private func groupSessions() {
        let calendar = Calendar.current
        let dict = Dictionary(grouping: sessions) { session in
            let components = calendar.dateComponents([.year, .month], from: session.startedAt)
            return calendar.date(from: components) ?? Date()
        }
        
        let sortedKeys = dict.keys.compactMap { $0 }.sorted(by: >)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        
        groupedSessions = sortedKeys.map { key in
            let monthString = formatter.string(from: key)
            return (month: monthString, sessions: dict[key] ?? [])
        }
    }
    
    func deleteSession(_ session: WorkoutSession) {
        // Optimistic remove from local state so the animation is immediate
        sessions.removeAll { $0.id == session.id }
        groupSessions()
        // Persist the deletion
        DataService.shared.deleteSession(session, context: modelContext)
    }
}
