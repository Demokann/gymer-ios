// MARK: - ExerciseListView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: ExerciseLibraryViewModel, ExerciseDetailView, NewExerciseView, BadgeLabel

import SwiftUI
import SwiftData

struct ExerciseListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExerciseLibraryViewModel()
    @State private var showingNewExercise = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    searchBar
                    
                    filterSection
                    
                    if viewModel.isLoading && viewModel.exercises.isEmpty {
                        ProgressView()
                            .tint(.gymLime)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.exercises.isEmpty {
                        emptyState
                    } else {
                        exerciseList
                    }
                }
                
                newExerciseButton
            }
            .navigationTitle("Exercises")
            .background(Color.gymBlack)
            .sheet(isPresented: $showingNewExercise) {
                NewExerciseView()
            }
            .task {
                await viewModel.loadExercises(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gymMuted)
            
            TextField("Search exercises...", text: Binding(
                get: { viewModel.searchText },
                set: { viewModel.search(query: $0) }
            ))
            .textFieldStyle(.plain)
            .foregroundColor(.gymWhite)
            .autocorrectionDisabled()
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.search(query: "") }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gymMuted)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.gymSurface)
        .cornerRadius(Radius.small)
        .padding(.horizontal)
        .padding(.top, Spacing.md)
    }
    
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                filterChip(title: "All", isSelected: viewModel.selectedRegion == nil) {
                    viewModel.selectRegion(nil)
                }
                
                ForEach(BodyRegion.allCases, id: \.self) { region in
                    filterChip(title: region.displayName, isSelected: viewModel.selectedRegion == region) {
                        viewModel.selectRegion(region)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, Spacing.md)
        }
    }
    
    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .medium)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? Color.gymLime : Color.gymSurface)
                .foregroundColor(isSelected ? .black : .gymWhite)
                .cornerRadius(Radius.pill)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.pill)
                        .stroke(Color.gymBorder, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
    
    private var exerciseList: some View {
        List {
            let grouped = Dictionary(grouping: viewModel.exercises) { String($0.name.prefix(1).uppercased()) }
            let keys = grouped.keys.sorted()
            
            ForEach(keys, id: \.self) { key in
                Section(header: Text(key).foregroundColor(.gymLime).font(.headline)) {
                    ForEach(grouped[key] ?? []) { exercise in
                        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                            exerciseRow(exercise)
                        }
                        .listRowBackground(Color.gymSurface)
                        .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.lg, bottom: Spacing.sm, trailing: Spacing.lg))
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.gymWhite)
                
                HStack(spacing: Spacing.xs) {
                    ForEach(exercise.bodyRegions.prefix(2), id: \.self) { region in
                        Text(region.displayName)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gymBlack.opacity(0.3))
                            .foregroundColor(.gymMuted)
                            .cornerRadius(Radius.small)
                    }
                    
                    if exercise.isCustom {
                        Text("Custom")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gymAmber.opacity(0.2))
                            .foregroundColor(.gymAmber)
                            .cornerRadius(Radius.small)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: exercise.equipment.icon)
                .foregroundColor(.gymMuted)
                .font(.subheadline)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "dumbbell")
                .font(.system(size: 48))
                .foregroundColor(.gymMuted)
            
            Text("No exercises found")
                .font(.headline)
                .foregroundColor(.gymWhite)
            
            Text("Try adjusting your search or filters.")
                .font(.subheadline)
                .foregroundColor(.gymMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var newExerciseButton: some View {
        Button(action: { showingNewExercise = true }) {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundColor(.black)
                .frame(width: 56, height: 56)
                .background(Color.gymLime)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
        }
        .padding(Spacing.xl)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Exercise.self, configurations: config)
    
    return ExerciseListView()
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
