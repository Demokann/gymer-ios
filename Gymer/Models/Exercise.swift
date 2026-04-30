import Foundation
import SwiftData

@Model
class Exercise {
    var id: UUID
    var name: String
    var bodyRegions: [BodyRegion]
    var equipment: Equipment
    var notes: String
    var isCustom: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), 
         name: String, 
         bodyRegions: [BodyRegion], 
         equipment: Equipment, 
         notes: String = "", 
         isCustom: Bool = false, 
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.bodyRegions = bodyRegions
        self.equipment = equipment
        self.notes = notes
        self.isCustom = isCustom
        self.createdAt = createdAt
    }
    
    var primaryRegion: BodyRegion {
        bodyRegions.first ?? .fullBody
    }
}
