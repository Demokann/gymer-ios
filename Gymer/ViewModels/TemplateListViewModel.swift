// MARK: - TemplateListViewModel
// Owner: Backend Dev Agent
// Last Modified: 03.05.2026
// Depends on: WorkoutTemplate, DataService

import SwiftUI
import SwiftData

@Observable @MainActor
class TemplateListViewModel {
    // MARK: - Published State
    var templates: [WorkoutTemplate] = []
    var isLoading = false
    var errorMessage: String? = nil
    
    // MARK: - Properties
    private let modelContext: ModelContext
    private let dataService = DataService.shared
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Intent
    func fetchTemplates() {
        isLoading = true
        let descriptor = FetchDescriptor<WorkoutTemplate>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        
        do {
            templates = try modelContext.fetch(descriptor)
            isLoading = false
        } catch {
            errorMessage = "Failed to load templates: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        dataService.deleteTemplate(template, context: modelContext)
        fetchTemplates()
    }
    
    func duplicateTemplate(_ template: WorkoutTemplate) {
        let newTemplate = WorkoutTemplate(
            name: "\(template.name) (Copy)",
            emoji: template.emoji,
            colorHex: template.colorHex
        )
        
        // Deep copy slots
        for slot in template.slots {
            let newSlot = ExerciseSlot(
                exercise: slot.exercise,
                order: slot.order,
                targetSets: slot.targetSets,
                targetReps: slot.targetReps,
                targetWeightKg: slot.targetWeightKg,
                defaultRestSeconds: slot.defaultRestSeconds,
                notes: slot.notes
            )
            newTemplate.slots.append(newSlot)
        }
        
        modelContext.insert(newTemplate)
        
        do {
            try modelContext.save()
            fetchTemplates()
        } catch {
            errorMessage = "Failed to duplicate template: \(error.localizedDescription)"
        }
    }
}
