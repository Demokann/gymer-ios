// MARK: - TemplateEditorView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: TemplateEditorViewModel, ExercisePickerView, GymButton, SectionHeader

import SwiftUI
import SwiftData

struct TemplateEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: TemplateEditorViewModel
    @State private var showingExercisePicker = false
    
    private let emojiOptions = ["💪", "🏋️‍♂️", "🏃‍♂️", "🚴‍♂️", "🧘‍♂️", "🥊", "🧗‍♂️", "🏊‍♂️", "🤸‍♂️", "🚣‍♂️", "🛹", "🏎️", "🏀", "⚽", "🏈", "🎾", "🏐", "🏒", "🏓", "🏸"]
    private let colorOptions = ["#C6FF00", "#FF3B30", "#FF9F0A", "#007AFF", "#AF52DE", "#5856D6", "#34C759", "#FF2D55"]
    
    // MARK: - Initialization
    init(modelContext: ModelContext, template: WorkoutTemplate? = nil) {
        _viewModel = State(initialValue: TemplateEditorViewModel(modelContext: modelContext, template: template))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Basic Info")
                            .font(.caption)
                            .foregroundColor(.gymMuted)
                            .textCase(.uppercase)
                            .padding(.leading, Spacing.sm)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: Spacing.md) {
                                emojiPicker
                                
                                TextField("Template Name", text: $viewModel.name)
                                    .font(.headline)
                                    .foregroundColor(.gymWhite)
                            }
                            .padding()
                            
                            Divider()
                                .background(Color.gymBorder)
                                .padding(.leading)
                            
                            colorPicker
                                .padding()
                        }
                        .background(Color.gymSurface)
                        .cornerRadius(Radius.medium)
                    }
                    
                    // Exercises Section
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        HStack {
                            Text("Exercises")
                                .font(.caption)
                                .foregroundColor(.gymMuted)
                                .textCase(.uppercase)
                            Spacer()
                            EditButton().font(.caption).foregroundColor(.gymLime)
                        }
                        .padding(.horizontal, Spacing.sm)
                        
                        VStack(spacing: 0) {
                            if viewModel.slots.isEmpty {
                                Text("No exercises added yet.")
                                    .foregroundColor(.gymMuted)
                                    .font(.subheadline)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                ForEach(viewModel.slots) { slot in
                                    VStack(spacing: 0) {
                                        HStack {
                                            exerciseSlotRow(slot)
                                            
                                            Button(role: .destructive) {
                                                if let index = viewModel.slots.firstIndex(where: { $0.id == slot.id }) {
                                                    viewModel.removeSlot(at: IndexSet(integer: index))
                                                }
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.gymRed)
                                                    .padding(.leading, Spacing.sm)
                                            }
                                        }
                                        .padding()
                                        
                                        if slot.id != viewModel.slots.last?.id {
                                            Divider()
                                                .background(Color.gymBorder)
                                                .padding(.leading)
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                                .background(Color.gymBorder)
                            
                            Button(action: { showingExercisePicker = true }) {
                                Label("Add Exercise", systemImage: "plus")
                                    .fontWeight(.bold)
                                    .foregroundColor(.gymLime)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .background(Color.gymSurface)
                        .cornerRadius(Radius.medium)
                    }
                }
                .padding()
            }
            .background(Color.gymBlack)
            .navigationTitle(viewModel.isNewTemplate ? "New Template" : "Edit Template")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gymMuted)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.save()
                        dismiss()
                    }
                    .foregroundColor(.gymLime)
                    .fontWeight(.bold)
                    .disabled(viewModel.name.isEmpty)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exercise in
                    viewModel.addExercise(exercise)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emojiPicker: some View {
        Menu {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5)) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button(action: { viewModel.emoji = emoji }) {
                            Text(emoji).font(.title)
                        }
                    }
                }
                .padding()
            }
        } label: {
            Text(viewModel.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(Color.gymBlack)
                .cornerRadius(Radius.small)
        }
    }
    
    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(colorOptions, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.gymWhite, lineWidth: viewModel.colorHex == hex ? 2 : 0)
                        )
                        .onTapGesture {
                            viewModel.colorHex = hex
                        }
                }
            }
            .padding(.vertical, Spacing.xs)
        }
    }
    
    private func exerciseSlotRow(_ slot: ExerciseSlot) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(slot.exercise.name)
                .font(.headline)
                .foregroundColor(.gymWhite)

            HStack(spacing: Spacing.lg) {
                stepperField(label: "Sets", value: Binding(
                    get: { Double(slot.targetSets) },
                    set: { slot.targetSets = Int($0) }
                ), range: 1...20, step: 1, format: "%.0f")

                stepperField(label: "Reps", value: Binding(
                    get: { Double(slot.targetReps) },
                    set: { slot.targetReps = Int($0) }
                ), range: 0...100, step: 1, format: slot.targetReps == 0 ? "F" : "%.0f")
            }

            RestTimerRowView(seconds: Binding(
                get: { slot.defaultRestSeconds },
                set: { slot.defaultRestSeconds = $0 }
            ))
        }
        .padding(.vertical, Spacing.xs)
    }

    private func stepperField(label: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, format: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.gymMuted)
                .textCase(.uppercase)
            
            HStack(spacing: Spacing.xs) {
                Text(String(format: format, value.wrappedValue))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.gymWhite)
                
                Stepper("", value: value, in: range, step: step)
                    .labelsHidden()
                    .scaleEffect(0.8)
            }
        }
    }
}

// MARK: - Exercise Picker View
struct ExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExerciseLibraryViewModel()
    
    var onSelect: (Exercise) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gymMuted)
                    TextField("Search exercises...", text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.search(query: $0) }
                    ))
                    .textFieldStyle(.plain)
                    .foregroundColor(.gymWhite)
                }
                .padding(Spacing.md)
                .background(Color.gymSurface)
                .cornerRadius(Radius.small)
                .padding()
                
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(BodyRegion.allCases, id: \.self) { region in
                            Button(action: { viewModel.selectRegion(viewModel.selectedRegion == region ? nil : region) }) {
                                Text(region.displayName)
                                    .font(.caption)
                                    .padding(.horizontal, Spacing.md)
                                    .padding(.vertical, Spacing.xs)
                                    .background(viewModel.selectedRegion == region ? Color.gymLime : Color.gymSurface)
                                    .foregroundColor(viewModel.selectedRegion == region ? .black : .gymWhite)
                                    .cornerRadius(Radius.pill)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, Spacing.md)
                
                // List
                List(viewModel.exercises) { exercise in
                    Button(action: {
                        onSelect(exercise)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .foregroundColor(.gymWhite)
                                Text(exercise.primaryRegion.displayName)
                                    .font(.caption)
                                    .foregroundColor(.gymMuted)
                            }
                            Spacer()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.gymLime)
                        }
                    }
                    .listRowBackground(Color.gymSurface)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.gymBlack)
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.gymLime)
                }
            }
            .task {
                await viewModel.loadExercises(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutTemplate.self, ExerciseSlot.self, Exercise.self, configurations: config)
    
    return TemplateEditorView(modelContext: container.mainContext)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
