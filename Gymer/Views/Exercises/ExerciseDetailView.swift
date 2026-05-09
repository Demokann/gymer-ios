// MARK: - ExerciseDetailView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: Exercise, DataService, BadgeLabel, Charts

import SwiftUI
import SwiftData
import Charts

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let exercise: Exercise
    
    @Query private var allSessions: [WorkoutSession]
    
    // MARK: - Computed Properties
    
    private var personalRecord: SetLog? {
        DataService.shared.personalRecord(for: exercise, context: modelContext)
    }
    
    private var volumeHistory: [VolumePoint] {
        let exerciseName = exercise.name
        
        // Filter sessions that have this exercise
        let relevantSessions = allSessions.filter { session in
            session.setLogs.contains { $0.exerciseName == exerciseName }
        }
        
        // Sort by date and take last 5
        let sortedSessions = relevantSessions.sorted(by: { $0.startedAt < $1.startedAt })
        let lastFive = sortedSessions.suffix(5)
        
        return lastFive.map { session in
            let volume = session.setLogs
                .filter { $0.exerciseName == exerciseName && !$0.isFailure }
                .reduce(0.0) { $0 + ($1.weightKg * Double($1.reps)) }
            return VolumePoint(date: session.startedAt, volume: volume)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                headerSection
                
                infoSection
                
                if !exercise.notes.isEmpty {
                    notesSection
                }
                
                statsSection
                
                chartSection
                
                Spacer(minLength: Spacing.xxl)
            }
            .padding()
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.gymBlack)
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(exercise.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.gymWhite)
                
                HStack(spacing: Spacing.sm) {
                    ForEach(exercise.bodyRegions, id: \.self) { region in
                        BadgeLabel(text: region.displayName, style: .system)
                    }
                    
                    if exercise.isCustom {
                        BadgeLabel(text: "Custom", style: .custom)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: exercise.equipment.icon)
                .font(.title2)
                .foregroundColor(.gymMuted)
                .padding(Spacing.md)
                .background(Color.gymSurface)
                .clipShape(Circle())
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Label("Equipment", systemImage: "info.circle")
                    .foregroundColor(.gymMuted)
                Spacer()
                Text(exercise.equipment.displayName)
                    .foregroundColor(.gymWhite)
                    .fontWeight(.medium)
            }
            
            Divider().background(Color.gymBorder)
            
            HStack {
                Label("Primary Muscle", systemImage: "figure.strengthtraining.traditional")
                    .foregroundColor(.gymMuted)
                Spacer()
                Text(exercise.primaryRegion.displayName)
                    .foregroundColor(.gymWhite)
                    .fontWeight(.medium)
            }
        }
        .padding(Spacing.lg)
        .background(Color.gymSurface)
        .cornerRadius(Radius.medium)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "Notes")
            
            Text(exercise.notes)
                .font(.body)
                .foregroundColor(.gymWhite)
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gymSurface)
                .cornerRadius(Radius.medium)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "Personal Record")
            
            if let pr = personalRecord {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(Formatters.weight(pr.weightKg))
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.gymLime)
                        
                        Text("\(pr.reps) reps")
                            .font(.subheadline)
                            .foregroundColor(.gymMuted)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: Spacing.xs) {
                        BadgeLabel(text: "PR", style: .pr)
                        
                        Text(pr.completedAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundColor(.gymMuted)
                    }
                }
                .padding(Spacing.lg)
                .background(Color.gymSurface)
                .cornerRadius(Radius.medium)
            } else {
                Text("No data yet. Log a workout to see your PR!")
                    .font(.subheadline)
                    .foregroundColor(.gymMuted)
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.gymSurface)
                    .cornerRadius(Radius.medium)
            }
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            SectionHeader(title: "Volume History")
            
            if volumeHistory.count >= 2 {
                VStack {
                    Chart {
                        ForEach(volumeHistory) { point in
                            BarMark(
                                x: .value("Date", point.date, unit: .day),
                                y: .value("Volume", point.volume)
                            )
                            .foregroundStyle(Color.gymLime.gradient)
                            .cornerRadius(Radius.small)
                        }
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { value in
                            AxisValueLabel(format: .dateTime.month().day())
                        }
                    }
                    .chartYAxis {
                        AxisMarks { value in
                            AxisValueLabel {
                                if let doubleValue = value.as(Double.self) {
                                    Text("\(Int(doubleValue))")
                                }
                            }
                        }
                    }
                    
                    Text("Total volume (weight × reps) for last 5 sessions")
                        .font(.caption)
                        .foregroundColor(.gymMuted)
                        .padding(.top, Spacing.sm)
                }
                .padding(Spacing.lg)
                .background(Color.gymSurface)
                .cornerRadius(Radius.medium)
            } else {
                Text("Log at least 2 sessions to see your progress chart.")
                    .font(.subheadline)
                    .foregroundColor(.gymMuted)
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.gymSurface)
                    .cornerRadius(Radius.medium)
            }
        }
    }
}

// MARK: - Helper Types

private struct VolumePoint: Identifiable {
    let id = UUID()
    let date: Date
    let volume: Double
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, WorkoutSession.self, SetLog.self, configurations: config)
    
    let exercise = Exercise(
        name: "Barbell Bench Press",
        bodyRegions: [.chest, .triceps, .shoulders],
        equipment: .barbell,
        notes: "Keep elbows at 75°, retract scapula"
    )
    
    return NavigationStack {
        ExerciseDetailView(exercise: exercise)
            .modelContainer(container)
    }
}
