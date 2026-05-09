// MARK: - TemplateEditorViewModel
// Owner: Backend Dev Agent
// Last Modified: 03.05.2026
// Depends on: WorkoutTemplate, ExerciseSlot, Exercise

import SwiftUI
import SwiftData

@Observable @MainActor
class TemplateEditorViewModel {
    // MARK: - Published State
    var name: String = ""
    var emoji: String = "💪"
    var colorHex: String = "#C6FF00"
    var slots: [ExerciseSlot] = []
    
    var isNewTemplate: Bool
    var template: WorkoutTemplate?
    
    // MARK: - Properties
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    init(modelContext: ModelContext, template: WorkoutTemplate? = nil) {
        self.modelContext = modelContext
        self.template = template
        self.isNewTemplate = template == nil
        
        if let template = template {
            self.name = template.name
            self.emoji = template.emoji
            self.colorHex = template.colorHex
            self.slots = template.slots.sorted(by: { $0.order < $1.order })
        }
    }
    
    // MARK: - Intents
    func addExercise(_ exercise: Exercise) {
        let order = (slots.map { $0.order }.max() ?? -1) + 1
        let newSlot = ExerciseSlot(exercise: exercise, order: order)
        slots.append(newSlot)
    }
    
    func removeSlot(at offsets: IndexSet) {
        slots.remove(atOffsets: offsets)
        // Re-order slots
        for (index, slot) in slots.enumerated() {
            slot.order = index
        }
    }
    
    func moveSlot(from source: IndexSet, to destination: Int) {
        slots.move(fromOffsets: source, toOffset: destination)
        // Re-order slots
        for (index, slot) in slots.enumerated() {
            slot.order = index
        }
    }
    
    func save() {
        if let template = template {
            template.name = name
            template.emoji = emoji
            template.colorHex = colorHex
            template.slots = slots
        } else {
            let newTemplate = WorkoutTemplate(
                name: name,
                emoji: emoji,
                colorHex: colorHex,
                slots: slots
            )
            modelContext.insert(newTemplate)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("❌ Error saving template: \(error)")
        }
    }
}
