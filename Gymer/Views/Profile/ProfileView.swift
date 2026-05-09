// MARK: - ProfileView
// Owner: UI Designer Agent
// Last Modified: 05.05.2026
// Dependencies: HomeViewModel, Formatters, GymFont, BadgeLabel, SetLog

import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var viewModel: HomeViewModel
    @AppStorage("userName") private var userName: String = "Gym Hero"
    @State private var isEditingName = false
    @FocusState private var isNameFocused: Bool
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: HomeViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    profileHeader
                    statsGrid
                    recentPRsSection
                    trainingDistributionSection
                }
                .padding(.vertical, Spacing.xl)
            }
            .background(Color.gymBlack)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchStats()
            }
        }
    }
    
    // MARK: - Subviews
    
    private var profileHeader: some View {
        VStack(spacing: Spacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .stroke(Color.gymLime, lineWidth: 2)
                    .frame(width: 84, height: 84)
                
                Text(userName.prefix(2).uppercased())
                    .gymFont(.title)
                    .foregroundStyle(Color.gymWhite)
                    .frame(width: 80, height: 80)
                    .background(Color.gymSurface)
                    .clipShape(Circle())
            }
            
            // Name
            VStack(spacing: Spacing.xs) {
                if isEditingName {
                    TextField("Enter name", text: $userName)
                        .textFieldStyle(.plain)
                        .gymFont(.title)
                        .foregroundStyle(Color.gymWhite)
                        .multilineTextAlignment(.center)
                        .focused($isNameFocused)
                        .onSubmit {
                            isEditingName = false
                        }
                } else {
                    Text(userName)
                        .gymFont(.title)
                        .foregroundStyle(Color.gymWhite)
                        .onTapGesture {
                            isEditingName = true
                            isNameFocused = true
                        }
                }
                
                Text("Member since May 2026")
                    .gymFont(.caption)
                    .foregroundStyle(Color.gymMuted)
            }
        }
    }
    
    private var statsGrid: some View {
        HStack(spacing: Spacing.md) {
            statBox(label: "Total\nWorkouts", value: "\(viewModel.totalWorkouts)")
            statBox(label: "This Month\nWorkouts", value: "\(viewModel.thisMonthWorkouts)")
            statBox(label: "Best\nStreak", value: "\(viewModel.bestStreak) days")
        }
        .padding(.horizontal, Spacing.lg)
    }
    
    private func statBox(label: String, value: String) -> some View {
        VStack(spacing: Spacing.sm) {
            Text(value)
                .gymFont(.title)
                .foregroundStyle(Color.gymLime)
            
            Text(label)
                .gymFont(.caption)
                .foregroundStyle(Color.gymMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(Color.gymSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
    }
    
    private var recentPRsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Recent PRs")
            
            if viewModel.recentPRs.isEmpty {
                Text("Complete workouts to earn PRs!")
                    .gymFont(.body)
                    .foregroundStyle(Color.gymMuted)
                    .padding(.horizontal, Spacing.lg)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(viewModel.recentPRs) { pr in
                        prRow(pr)
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
    
    private func prRow(_ pr: SetLog) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(pr.exerciseName)
                    .gymFont(.body)
                    .foregroundStyle(Color.gymWhite)
                Text(pr.completedAt.formatted(date: .abbreviated, time: .omitted))
                    .gymFont(.caption)
                    .foregroundStyle(Color.gymMuted)
            }
            
            Spacer()
            
            Text("\(Formatters.formatWeight(pr.weightKg)) × \(pr.reps)")
                .gymFont(.body)
                .foregroundStyle(Color.gymLime)
                .bold()
        }
        .padding(Spacing.md)
        .background(Color.gymSurface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
    }
    
    private var trainingDistributionSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Favourite Body Regions")
            
            if viewModel.bodyRegionDistribution.isEmpty {
                Text("Start training to see your distribution.")
                    .gymFont(.body)
                    .foregroundStyle(Color.gymMuted)
                    .padding(.horizontal, Spacing.lg)
            } else {
                VStack(spacing: Spacing.md) {
                    let maxCount = viewModel.bodyRegionDistribution.first?.count ?? 1
                    
                    ForEach(viewModel.bodyRegionDistribution.prefix(5), id: \.region) { item in
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            HStack {
                                Text(item.region.displayName)
                                    .gymFont(.caption)
                                    .foregroundStyle(Color.gymWhite)
                                Spacer()
                                Text("\(item.count) sets")
                                    .gymFont(.caption)
                                    .foregroundStyle(Color.gymMuted)
                            }
                            
                            GeometryReader { geo in
                                RoundedRectangle(cornerRadius: Radius.pill)
                                    .fill(Color.gymBorder)
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: Radius.pill)
                                    .fill(Color.gymLime)
                                    .frame(width: geo.size.width * CGFloat(item.count) / CGFloat(maxCount), height: 8)
                            }
                            .frame(height: 8)
                        }
                    }
                }
                .padding(.horizontal, Spacing.lg)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, ExerciseSlot.self, SetLog.self, Exercise.self, configurations: config)
    
    return ProfileView(modelContext: container.mainContext)
        .modelContainer(container)
}
