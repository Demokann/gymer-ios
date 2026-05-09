// MARK: - MainTabView
// Owner: UI Designer Agent
// Last Modified: 05.05.2026
// Dependencies: ProfileView, HistoryView, StartWorkoutView, ExerciseListView, Color, Spacing

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0
    @State private var isShowingStartWorkout = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                ProfileView(modelContext: modelContext)
                    .tag(0)
                
                HistoryView(modelContext: modelContext)
                    .tag(1)
                
                // Placeholder for the centre button action
                Color.gymBlack
                    .tag(2)
                
                ExerciseListView()
                    .tag(3)
            }
            
            // Custom Tab Bar Background
            VStack(spacing: 0) {
                Divider()
                    .background(Color.gymBorder)
                
                HStack(spacing: 0) {
                    tabItem(index: 0, icon: "person.fill", label: "Profile")
                    tabItem(index: 1, icon: "clock.fill", label: "History")
                    // Equal-width placeholder keeps centre button exactly mid-screen
                    Color.clear.frame(maxWidth: .infinity)
                    tabItem(index: 3, icon: "dumbbell.fill", label: "Exercises")
                }
                .padding(.top, Spacing.sm)
                .padding(.bottom, 34) // Safe area bottom approx
                .background(Color.gymSurface)
            }
            
            // Oversized Centre Button
            Button {
                isShowingStartWorkout = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.gymLime)
                        .frame(width: 56, height: 56)
                        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.black)
                }
            }
            .offset(y: -20) // Lift above the tab bar
        }
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $isShowingStartWorkout) {
            StartWorkoutView(modelContext: modelContext)
        }
    }
    
    private func tabItem(index: Int, icon: String, label: String) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .gymFont(.caption)
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == index ? Color.gymLime : Color.gymMuted)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, ExerciseSlot.self, SetLog.self, Exercise.self, configurations: config)
    
    return MainTabView()
        .modelContainer(container)
}
