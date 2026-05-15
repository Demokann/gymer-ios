// MARK: - HistoryView
// Owner: UI Designer Agent
// Last Modified: 05.05.2026
// Dependencies: HistoryViewModel, WorkoutSession, WorkoutDetailView, Formatters

import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: HistoryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            HistoryListView(viewModel: viewModel)
                .navigationTitle("History")
                .onAppear {
                    viewModel.fetchHistory()
                }
        }
    }
}

struct HistoryListView: View {
    var viewModel: HistoryViewModel

    var body: some View {
        ZStack {
            Color.gymBlack.ignoresSafeArea()

            if viewModel.sessions.isEmpty && !viewModel.isLoading {
                emptyState
            } else {
                workoutList
            }
        }
    }

    // MARK: - Subviews

    private var workoutList: some View {
        List {
            ForEach(viewModel.groupedSessions, id: \.month) { group in
                Section {
                    ForEach(group.sessions) { session in
                        HStack(spacing: Spacing.md) {
                            Button {
                                withAnimation {
                                    viewModel.deleteSession(session)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color.gymRed)
                                    .padding(8)
                                    .background(Color.gymSurface)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)

                            NavigationLink {
                                WorkoutDetailView(session: session)
                            } label: {
                                workoutRow(session)
                            }
                        }
                        .listRowBackground(Color.gymSurface)
                        .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.lg, bottom: Spacing.sm, trailing: Spacing.lg))
                    }
                } header: {
                    Text(group.month)
                        .gymFont(.caption)
                        .foregroundStyle(Color.gymMuted)
                        .padding(.top, Spacing.md)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func workoutRow(_ session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text(session.template?.emoji ?? "💪")
                Text(session.templateName)
                    .gymFont(.body)
                    .bold()
                    .foregroundStyle(Color.gymWhite)
                
                Spacer()
                
                Text(session.startedAt.formatted(.dateTime.day().month().weekday()))
                    .gymFont(.caption)
                    .foregroundStyle(Color.gymMuted)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(session.durationFormatted) · \(session.exerciseCount) exercises · \(Formatters.formatVolume(session.totalVolumeKg)) vol")
                        .gymFont(.caption)
                        .foregroundStyle(Color.gymMuted)
                }
                
                Spacer()
                
                let prCount = session.setLogs.filter { $0.isPersonalRecord }.count
                if prCount > 0 {
                    HStack(spacing: 4) {
                        Text("🏆")
                        Text("\(prCount) PRs")
                    }
                    .gymFont(.caption)
                    .foregroundStyle(Color.gymLime)
                    .bold()
                }
            }
        }
        .padding(.vertical, Spacing.xs)
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundStyle(Color.gymMuted)
            
            VStack(spacing: Spacing.xs) {
                Text("No Workouts Yet")
                    .gymFont(.title)
                    .foregroundStyle(Color.gymWhite)
                
                Text("Your completed workouts will appear here.")
                    .gymFont(.body)
                    .foregroundStyle(Color.gymMuted)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(Spacing.xxl)
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, ExerciseSlot.self, SetLog.self, Exercise.self, configurations: config)
    
    return HistoryView(modelContext: container.mainContext)
        .modelContainer(container)
}
