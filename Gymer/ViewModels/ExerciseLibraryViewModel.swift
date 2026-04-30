// MARK: - ExerciseLibraryViewModel
// Owner: Backend Dev Agent
// Last Modified: 2026-04-30
// Depends on: Exercise, ExerciseLibraryService, BodyRegion

import SwiftUI
import SwiftData
import Observation

@Observable
@MainActor
class ExerciseLibraryViewModel {
    // MARK: - Published State
    var searchText: String = ""
    var selectedRegion: BodyRegion? = nil
    var exercises: [Exercise] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    
    private let service = ExerciseLibraryService.shared
    
    // MARK: - Intent
    func loadExercises(modelContext: ModelContext) async {
        isLoading = true
        await service.loadExercises(modelContext: modelContext)
        updateFilteredExercises()
        isLoading = false
    }
    
    func selectRegion(_ region: BodyRegion?) {
        selectedRegion = region
        updateFilteredExercises()
    }
    
    func search(query: String) {
        searchText = query
        updateFilteredExercises()
    }
    
    // MARK: - Private Logic
    private func updateFilteredExercises() {
        var results = service.allExercises
        
        // Filter by region
        if let region = selectedRegion {
            results = results.filter { $0.bodyRegions.contains(region) }
        }
        
        // Search by text
        if !searchText.isEmpty {
            results = results.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        self.exercises = results.sorted(by: { $0.name < $1.name })
    }
}
