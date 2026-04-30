// MARK: - ExerciseLibraryService
// Owner: Backend Dev Agent
// Last Modified: 28.04.2026
// Depends on: Exercise Model, exercises.json

import Foundation
import SwiftData

@MainActor
@Observable
class ExerciseLibraryService {
    static let shared = ExerciseLibraryService()
    
    private(set) var allExercises: [Exercise] = []
    
    private init() {}
    
    func loadExercises(modelContext: ModelContext) async {
        // 1. Load from bundled JSON
        guard let url = Bundle.main.url(forResource: "exercises", withExtension: "json") else {
            print("❌ exercises.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decodedExercises = try decoder.decode([ExerciseDTO].self, from: data)
            
            // 2. Fetch custom exercises from SwiftData
            let descriptor = FetchDescriptor<Exercise>(predicate: #Predicate { $0.isCustom == true })
            let customExercises = try modelContext.fetch(descriptor)
            
            // 3. Combine and cache
            let bundledExercises = decodedExercises.map { dto in
                Exercise(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    name: dto.name,
                    bodyRegions: dto.bodyRegions,
                    equipment: dto.equipment,
                    notes: dto.notes,
                    isCustom: false
                )
            }
            
            self.allExercises = (bundledExercises + customExercises).sorted(by: { $0.name < $1.name })
            
        } catch {
            print("❌ Error loading exercises: \(error)")
        }
    }
    
    func exercises(for region: BodyRegion) -> [Exercise] {
        allExercises.filter { $0.bodyRegions.contains(region) }
    }
    
    func search(_ query: String) -> [Exercise] {
        guard !query.isEmpty else { return allExercises }
        return allExercises.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }
}

// Data Transfer Object for JSON decoding
private struct ExerciseDTO: Codable {
    let id: String
    let name: String
    let bodyRegions: [BodyRegion]
    let equipment: Equipment
    let notes: String
}
