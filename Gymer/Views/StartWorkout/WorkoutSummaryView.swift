// MARK: - WorkoutSummaryView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: WorkoutSession, SetLog, Formatters, GymButton

import SwiftUI
import SwiftData

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    
    private var personalRecords: [SetLog] {
        session.setLogs.filter { $0.isPersonalRecord }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    headerSection
                    
                    statsGrid
                    
                    if !personalRecords.isEmpty {
                        personalRecordsSection
                    }
                    
                    Spacer(minLength: Spacing.xl)
                    
                    doneButton
                }
                .padding()
            }
            .background(Color.gymBlack)
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: Spacing.md) {
            Text("🎉")
                .font(.system(size: 80))
            
            Text("Workout Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.gymWhite)
            
            Text(session.templateName)
                .font(.headline)
                .foregroundColor(.gymLime)
            
            Text(session.startedAt.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(.gymMuted)
        }
        .padding(.top, Spacing.xxl)
    }
    
    private var statsGrid: some View {
        VStack(spacing: Spacing.md) {
            HStack(spacing: Spacing.md) {
                statCard(label: "Duration", value: session.durationFormatted, icon: "clock")
                statCard(label: "Volume", value: Formatters.formatVolume(session.totalVolumeKg), icon: "scalemass")
            }
            
            HStack(spacing: Spacing.md) {
                statCard(label: "Sets", value: "\(session.setLogs.count)", icon: "list.bullet")
                statCard(label: "PRs", value: "\(personalRecords.count)", icon: "trophy")
            }
        }
    }
    
    private func statCard(label: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.gymMuted)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.gymWhite)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gymSurface)
        .cornerRadius(Radius.medium)
    }
    
    private var personalRecordsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Personal Records")
            
            ForEach(personalRecords) { log in
                HStack {
                    VStack(alignment: .leading) {
                        Text(log.exerciseName)
                            .font(.headline)
                            .foregroundColor(.gymWhite)
                        Text("\(Formatters.weight(log.weightKg)) × \(log.reps) reps")
                            .font(.subheadline)
                            .foregroundColor(.gymMuted)
                    }
                    Spacer()
                    BadgeLabel(text: "NEW PR", style: .pr)
                }
                .padding()
                .background(Color.gymSurface)
                .cornerRadius(Radius.medium)
            }
        }
    }
    
    private var doneButton: some View {
        Button(action: { dismiss() }) {
            Text("Done")
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(Color.gymLime)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    WorkoutSummaryView(session: {
        let session = WorkoutSession(templateName: "Upper Body")
        session.finishedAt = Date().addingTimeInterval(3600)
        session.setLogs = [
            SetLog(exerciseName: "Bench Press", setIndex: 1, weightKg: 100, reps: 5, isPersonalRecord: true),
            SetLog(exerciseName: "Rows", setIndex: 1, weightKg: 80, reps: 10)
        ]
        return session
    }())
    .preferredColorScheme(.dark)
}
