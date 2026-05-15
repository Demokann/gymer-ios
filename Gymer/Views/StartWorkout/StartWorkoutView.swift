// MARK: - StartWorkoutView
// Owner: UI Designer Agent
// Last Modified: 04.05.2026
// Dependencies: TemplateListViewModel, ActiveWorkoutView, TemplateEditorView, GymButton

import SwiftUI
import SwiftData

struct StartWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(TimerService.self) private var timerService
    
    @State private var viewModel: TemplateListViewModel
    @State private var historyViewModel: HistoryViewModel
    @State private var selectedSegment = 0 // 0: Workouts, 1: History
    
    @State private var showingTemplateEditor = false
    @State private var selectedTemplate: WorkoutTemplate?
    @State private var showingActiveWorkout = false
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: TemplateListViewModel(modelContext: modelContext))
        _historyViewModel = State(initialValue: HistoryViewModel(modelContext: modelContext))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("View", selection: $selectedSegment) {
                    Text("Workouts").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.gymBlack)
                
                if selectedSegment == 0 {
                    workoutsContent
                } else {
                    HistoryListView(viewModel: historyViewModel)
                }
            }
            .background(Color.gymBlack)
            .navigationTitle(selectedSegment == 0 ? "Start Workout" : "History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.gymMuted)
                }
            }
            .task {
                if selectedSegment == 0 {
                    viewModel.fetchTemplates()
                } else {
                    historyViewModel.fetchHistory()
                }
            }
            .onChange(of: selectedSegment) { _, newValue in
                if newValue == 0 {
                    viewModel.fetchTemplates()
                } else {
                    historyViewModel.fetchHistory()
                }
            }
            .sheet(isPresented: $showingTemplateEditor, onDismiss: {
                viewModel.fetchTemplates()
            }) {
                TemplateEditorView(modelContext: modelContext)
            }
            .fullScreenCover(isPresented: $showingActiveWorkout) {
                ActiveWorkoutView(modelContext: modelContext, timerService: timerService, template: selectedTemplate)
                    .environment(timerService)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var workoutsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xxl) {
                templatesSection
                
                quickStartSection
            }
            .padding()
        }
    }
    
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "My Templates")
            
            if viewModel.templates.isEmpty {
                Text("No templates yet. Create one to speed up your workout!")
                    .font(.subheadline)
                    .foregroundColor(.gymMuted)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gymSurface)
                    .cornerRadius(Radius.medium)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.md) {
                        ForEach(viewModel.templates) { template in
                            templateCard(template)
                        }
                    }
                }
            }
        }
    }
    
    private func templateCard(_ template: WorkoutTemplate) -> some View {
        Button(action: {
            selectedTemplate = template
            showingActiveWorkout = true
        }) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(template.emoji)
                    .font(.largeTitle)
                
                Spacer()
                
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.gymWhite)
                    .lineLimit(2)
                
                Text("\(template.slots.count) exercises")
                    .font(.caption)
                    .foregroundColor(.gymMuted)
                
                if let lastUsed = template.lastUsedAt {
                    Text("Last: \(lastUsed.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 10))
                        .foregroundColor(.gymMuted)
                }
            }
            .padding()
            .frame(width: 150, height: 180, alignment: .leading)
            .background(Color.gymSurface)
            .cornerRadius(Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.medium)
                    .stroke(Color(hex: template.colorHex), lineWidth: 2)
                    .opacity(0.5)
            )
            .overlay(
                Rectangle()
                    .fill(Color(hex: template.colorHex))
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
                    .padding(.vertical, Spacing.lg),
                alignment: .leading
            )
        }
        .contextMenu {
            Button {
                // Edit template
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                viewModel.duplicateTemplate(template)
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            
            Button(role: .destructive) {
                viewModel.deleteTemplate(template)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeader(title: "Quick Start")
            
            Button(action: { 
                selectedTemplate = nil
                showingActiveWorkout = true
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                    Text("Start Empty Workout")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(Color.gymLime)
                .foregroundColor(.black)
                .cornerRadius(Radius.medium)
            }
            
            Button(action: { showingTemplateEditor = true }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Create New Template")
                        .fontWeight(.bold)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .padding()
                .background(Color.gymSurface)
                .foregroundColor(.gymWhite)
                .cornerRadius(Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.medium)
                        .stroke(Color.gymBorder, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: WorkoutTemplate.self, ExerciseSlot.self, WorkoutSession.self, SetLog.self, Exercise.self, configurations: config)
    let timerService = TimerService()
    
    return StartWorkoutView(modelContext: container.mainContext)
        .modelContainer(container)
        .environment(timerService)
        .preferredColorScheme(.dark)
}
