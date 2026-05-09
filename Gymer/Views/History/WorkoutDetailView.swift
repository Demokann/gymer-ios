// MARK: - WorkoutDetailView
// Owner: UI Designer Agent
// Last Modified: 05.05.2026
// Dependencies: WorkoutSession, SetLog, Formatters, GymFont, BadgeLabel

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let session: WorkoutSession
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                headerSection
                statsSection
                exercisesList
            }
            .padding(.vertical, Spacing.lg)
        }
        .background(Color.gymBlack)
        .navigationTitle(session.templateName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                .gymFont(.caption)
                .foregroundStyle(Color.gymMuted)
            
            Text(session.durationFormatted)
                .gymFont(.title)
                .foregroundStyle(Color.gymWhite)
        }
        .padding(.horizontal, Spacing.lg)
    }
    
    private var statsSection: some View {
        HStack(spacing: Spacing.md) {
            statItem(label: "Volume", value: Formatters.formatVolume(session.totalVolumeKg))
            statItem(label: "Sets", value: "\(session.setLogs.count)")
            statItem(label: "Exercises", value: "\(session.exerciseCount)")
        }
        .padding(.horizontal, Spacing.lg)
    }
    
    private func statItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(label.uppercased())
                .gymFont(.caption)
                .foregroundStyle(Color.gymMuted)
            Text(value)
                .gymFont(.body)
                .foregroundStyle(Color.gymWhite)
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.gymSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
    }
    
    private var exercisesList: some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            ForEach(groupedLogs, id: \.key) { exerciseName, logs in
                VStack(alignment: .leading, spacing: Spacing.md) {
                    HStack {
                        Text(exerciseName)
                            .gymFont(.body)
                            .bold()
                            .foregroundStyle(Color.gymWhite)
                        
                        Spacer()
                        
                        if let firstLog = logs.first, let exercise = firstLog.exercise {
                            BadgeLabel(text: exercise.primaryRegion.displayName, style: .region)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        ForEach(logs.sorted(by: { $0.setIndex < $1.setIndex })) { log in
                            setLogRow(log)
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
    
    private func setLogRow(_ log: SetLog) -> some View {
        HStack(spacing: Spacing.md) {
            Text("\(log.setIndex)")
                .gymFont(.caption)
                .foregroundStyle(Color.gymMuted)
                .frame(width: 20, alignment: .leading)
            
            HStack(spacing: Spacing.xs) {
                Text(Formatters.formatWeight(log.weightKg))
                Text("×")
                Text(log.isFailure ? "F" : "\(log.reps)")
            }
            .gymFont(.body)
            .foregroundStyle(Color.gymWhite)
            
            Spacer()
            
            HStack(spacing: Spacing.sm) {
                if log.setType != .regular {
                    BadgeLabel(text: log.setType.rawValue, style: log.setType == .warmUp ? .warmUp : .dropSet)
                }
                
                if log.isPersonalRecord {
                    BadgeLabel(text: "PR", style: .pr)
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
    
    // MARK: - Helper Data
    
    private var groupedLogs: [(key: String, value: [SetLog])] {
        let dict = Dictionary(grouping: session.setLogs) { $0.exerciseName }
        return dict.sorted { $0.key < $1.key }.map { (key: $0.key, value: $0.value) }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, ExerciseSlot.self, SetLog.self, Exercise.self, configurations: config)
    
    let session = WorkoutSession(
        templateName: "Push Day A",
        startedAt: Date().addingTimeInterval(-3600),
        finishedAt: Date(),
        notes: "Great workout!"
    )
    
    let bench = Exercise(id: UUID(), name: "Barbell Bench Press", bodyRegions: [.chest], equipment: .barbell, notes: "", isCustom: false, createdAt: Date())
    
    let log1 = SetLog(exercise: bench, exerciseName: "Barbell Bench Press", setIndex: 1, setType: .warmUp, weightKg: 60, reps: 12, isPersonalRecord: false)
    let log2 = SetLog(exercise: bench, exerciseName: "Barbell Bench Press", setIndex: 2, setType: .regular, weightKg: 100, reps: 8, isPersonalRecord: true)
    
    session.setLogs = [log1, log2]
    container.mainContext.insert(session)
    
    return NavigationStack {
        WorkoutDetailView(session: session)
            .modelContainer(container)
    }
}
