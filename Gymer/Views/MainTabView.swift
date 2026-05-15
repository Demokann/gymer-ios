// MARK: - MainTabView
// Owner: UI Designer Agent
// Last Modified: 2026-05-15
// Dependencies: ProfileView, StartWorkoutView, ExerciseListView, Color, Spacing

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(TimerService.self) private var timerService
    // 0=Profile, 1=StartWorkout, 2=Exercises
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                ProfileView(modelContext: modelContext)
                    .tag(0)

                StartWorkoutView(modelContext: modelContext)
                    .tag(1)

                ExerciseListView()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            // Custom Tab Bar
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gymBorder)

                HStack {
                    tabButton(title: "Profile", icon: "person.fill", index: 0)

                    Spacer() // Space for the centre button
                        .frame(width: 80)

                    tabButton(title: "Exercises", icon: "figure.strengthtraining.traditional", index: 2)
                }
                .padding(.horizontal, Spacing.xl)
                .frame(height: 60)
                .background(Color.gymBlack.opacity(0.95))
            }

            // Centre START WORKOUT button — tapping navigates to the Start Workout tab
            Button {
                withAnimation {
                    selectedTab = 1
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(selectedTab == 1 ? Color.gymLime.opacity(0.85) : Color.gymLime)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)

                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }
            .offset(y: -34)
        }
    }

    private func tabButton(title: String, icon: String, index: Int) -> some View {
        Button {
            withAnimation {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(selectedTab == index ? .gymLime : .gymMuted)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, ExerciseSlot.self, SetLog.self, Exercise.self, configurations: config)
    let timerService = TimerService()

    return MainTabView()
        .modelContainer(container)
        .environment(timerService)
}
