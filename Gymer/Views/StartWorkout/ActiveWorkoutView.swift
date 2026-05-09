// MARK: - ActiveWorkoutView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: ActiveWorkoutViewModel, SetRowView, RestTimerOverlay, ExercisePickerView, Formatters

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(TimerService.self) private var timerService
    
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var showingExercisePicker = false
    @State private var showingRestTimer = false
    @State private var showingFinishConfirmation = false
    @State private var showingCancelConfirmation = false
    @State private var workoutNotes = ""
    
    // MARK: - Initialization
    init(modelContext: ModelContext, timerService: TimerService, template: WorkoutTemplate? = nil) {
        _viewModel = State(initialValue: ActiveWorkoutViewModel(modelContext: modelContext, timerService: timerService, template: template))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        ForEach(Array(viewModel.exerciseStates.enumerated()), id: \.1.id) { exerciseIndex, exerciseState in
                            exerciseSection(exerciseIndex: exerciseIndex, exerciseState: exerciseState)
                        }
                        
                        addExerciseButton
                        
                        Spacer(minLength: 100) // Padding for rest timer banner
                    }
                    .padding()
                }
                
                if timerService.isRunning {
                    restTimerBanner
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.gymBlack)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showingCancelConfirmation = true }
                        .foregroundColor(.gymRed)
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(viewModel.template?.name ?? "Empty Workout")
                            .font(.headline)
                            .foregroundColor(.gymWhite)
                        Text(Formatters.formatRestTimer(viewModel.elapsedTime))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.gymLime)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Finish") { showingFinishConfirmation = true }
                        .foregroundColor(.gymLime)
                        .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ExercisePickerView { exercise in
                    viewModel.addExercise(exercise)
                }
            }
            .sheet(isPresented: $showingRestTimer) {
                RestTimerOverlay()
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $viewModel.isFinished) {
                if let session = viewModel.workoutSession {
                    WorkoutSummaryView(session: session)
                }
            }
            .alert("Cancel Workout?", isPresented: $showingCancelConfirmation) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Continue", role: .cancel) {}
            } message: {
                Text("All progress in this session will be lost.")
            }
            .alert("Finish Workout?", isPresented: $showingFinishConfirmation) {
                TextField("Add notes...", text: $workoutNotes)
                Button("Finish", action: { viewModel.finishWorkout(notes: workoutNotes) })
                Button("Resume", role: .cancel) {}
            } message: {
                Text("Ready to log your progress?")
            }
            .onChange(of: timerService.isRunning) { _, isRunning in
                if isRunning {
                    showingRestTimer = true
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private func exerciseSection(exerciseIndex: Int, exerciseState: ExerciseState) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exerciseState.exercise.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.gymWhite)
                    
                    HStack(spacing: Spacing.xs) {
                        ForEach(exerciseState.exercise.bodyRegions.prefix(2), id: \.self) { region in
                            BadgeLabel(text: region.displayName, style: .system)
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button(role: .destructive, action: { 
                        // Add remove exercise logic to VM if needed
                    }) {
                        Label("Remove Exercise", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gymMuted)
                        .padding(Spacing.sm)
                }
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(Array(exerciseState.sets.enumerated()), id: \.1.id) { setIndex, setState in
                    SetRowView(
                        setIndex: setIndex + 1,
                        weight: Binding(
                            get: { setState.weightKg },
                            set: { viewModel.updateWeight($0, for: exerciseIndex, setIndex: setIndex) }
                        ),
                        reps: Binding(
                            get: { setState.reps },
                            set: { viewModel.updateReps($0, for: exerciseIndex, setIndex: setIndex) }
                        ),
                        setType: Binding(
                            get: { setState.type },
                            set: { viewModel.updateSetType($0, for: exerciseIndex, setIndex: setIndex) }
                        ),
                        isFailure: Binding(
                            get: { setState.isFailure },
                            set: { _ in viewModel.toggleFailure(for: exerciseIndex, setIndex: setIndex) }
                        ),
                        isCompleted: setState.isCompleted,
                        onComplete: {
                            viewModel.completeSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
                        }
                    )
                }
            }
            
            Button(action: { viewModel.addSet(to: exerciseIndex) }) {
                Label("Add Set", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.gymMuted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(Color.gymSurface)
                    .cornerRadius(Radius.small)
            }
        }
        .padding()
        .background(Color.gymSurface.opacity(0.5))
        .cornerRadius(Radius.medium)
    }
    
    private var addExerciseButton: some View {
        Button(action: { showingExercisePicker = true }) {
            Label("Add Exercise", systemImage: "plus.circle")
                .font(.headline)
                .foregroundColor(.gymLime)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: Radius.medium)
                        .stroke(Color.gymLime, lineWidth: 1)
                )
        }
    }
    
    private var restTimerBanner: some View {
        Button(action: { showingRestTimer = true }) {
            HStack {
                Image(systemName: "timer")
                Text("REST \(Formatters.formatRestTimer(timerService.secondsRemaining))")
                    .font(.system(.body, design: .monospaced))
                Spacer()
                Text("TAP TO EXPAND")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            .foregroundColor(.black)
            .padding(.horizontal, Spacing.lg)
            .frame(height: 44)
            .background(Color.gymLime)
            .cornerRadius(Radius.pill)
            .padding(.horizontal)
            .padding(.bottom, Spacing.md)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutSession.self, WorkoutTemplate.self, SetLog.self, Exercise.self, ExerciseSlot.self, configurations: config)
    let timerService = TimerService()
    
    return ActiveWorkoutView(modelContext: container.mainContext, timerService: timerService)
        .modelContainer(container)
        .environment(timerService)
        .preferredColorScheme(.dark)
}
