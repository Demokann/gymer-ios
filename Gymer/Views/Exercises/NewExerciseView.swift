// MARK: - NewExerciseView
// Owner: UI Designer Agent
// Last Modified: 03.05.2026
// Dependencies: DataService, BodyRegion, Equipment, GymButton, BadgeLabel

import SwiftUI
import SwiftData

struct NewExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var primaryRegion: BodyRegion = .chest
    @State private var secondaryRegions: Set<BodyRegion> = []
    @State private var equipment: Equipment = .barbell
    @State private var notes: String = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150))
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    // Name Section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("EXERCISE NAME")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                        
                        TextField("e.g. Barbell Bench Press", text: $name)
                            .gymFont(.body)
                            .padding()
                            .background(Color.gymSurface)
                            .cornerRadius(Radius.medium)
                            .foregroundColor(.gymWhite)
                    }
                    
                    // Primary Muscle Section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("PRIMARY MUSCLE")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                        
                        LazyVGrid(columns: columns, spacing: Spacing.sm) {
                            ForEach(BodyRegion.allCases, id: \.self) { region in
                                Button {
                                    primaryRegion = region
                                    secondaryRegions.remove(region)
                                } label: {
                                    Text(region.displayName)
                                        .gymFont(.caption)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(primaryRegion == region ? Color.gymLime : Color.gymSurface)
                                        .foregroundColor(primaryRegion == region ? .black : .gymWhite)
                                        .cornerRadius(Radius.pill)
                                }
                            }
                        }
                    }
                    
                    // Secondary Muscles Section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("SECONDARY MUSCLES")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                        
                        LazyVGrid(columns: columns, spacing: Spacing.sm) {
                            ForEach(BodyRegion.allCases.filter { $0 != primaryRegion }, id: \.self) { region in
                                Button {
                                    if secondaryRegions.contains(region) {
                                        secondaryRegions.remove(region)
                                    } else {
                                        secondaryRegions.insert(region)
                                    }
                                } label: {
                                    Text(region.displayName)
                                        .gymFont(.caption)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(secondaryRegions.contains(region) ? Color.gymLime.opacity(0.3) : Color.gymSurface)
                                        .foregroundColor(secondaryRegions.contains(region) ? .gymLime : .gymWhite)
                                        .cornerRadius(Radius.pill)
                                }
                            }
                        }
                    }
                    
                    // Equipment Section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("EQUIPMENT")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Spacing.sm) {
                                ForEach(Equipment.allCases, id: \.self) { item in
                                    Button {
                                        equipment = item
                                    } label: {
                                        Text(item.rawValue.capitalized)
                                            .gymFont(.caption)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(equipment == item ? Color.gymLime : Color.gymSurface)
                                            .foregroundColor(equipment == item ? .black : .gymWhite)
                                            .cornerRadius(Radius.pill)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("NOTES")
                            .gymFont(.caption)
                            .foregroundColor(.gymMuted)
                        
                        TextField("Add any tips or form notes...", text: $notes, axis: .vertical)
                            .gymFont(.body)
                            .lineLimit(3...6)
                            .padding()
                            .background(Color.gymSurface)
                            .cornerRadius(Radius.medium)
                            .foregroundColor(.gymWhite)
                    }
                    
                    GymButton("Save Exercise") {
                        saveExercise()
                    }
                    .disabled(name.isEmpty)
                    .padding(.top, Spacing.lg)
                }
                .padding(Spacing.lg)
            }
            .background(Color.gymBlack)
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gymLime)
                }
            }
        }
    }
    
    private func saveExercise() {
        let regions = [primaryRegion] + Array(secondaryRegions)
        let newExercise = Exercise(
            name: name,
            bodyRegions: regions,
            equipment: equipment,
            notes: notes,
            isCustom: true
        )
        
        DataService.shared.saveExercise(newExercise, context: modelContext)
        dismiss()
    }
}

#Preview {
    NewExerciseView()
        .preferredColorScheme(.dark)
}
