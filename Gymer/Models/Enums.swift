import SwiftUI

enum BodyRegion: String, Codable, CaseIterable {
    case chest, back, shoulders, biceps, triceps
    case quads, hamstrings, glutes, calves, abs, fullBody
    
    var displayName: String {
        switch self {
        case .fullBody: return "Full Body"
        default: return self.rawValue.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .chest: return "figure.cooldown"
        case .back: return "figure.core.training"
        case .shoulders: return "figure.arms.open"
        case .biceps, .triceps: return "figure.strengthtraining.traditional"
        case .quads, .hamstrings, .glutes, .calves: return "figure.strengthtraining.functional"
        case .abs: return "figure.core.training"
        case .fullBody: return "figure.run"
        }
    }
}

enum SetType: String, Codable, CaseIterable {
    case regular = "Regular"
    case warmUp  = "Warm-up"
    case dropSet = "Drop Set"
    
    var color: Color {
        switch self {
        case .regular: return .gymWhite
        case .warmUp:  return .gymAmber
        case .dropSet: return .gymRed
        }
    }
    
    var abbreviation: String {
        switch self {
        case .regular: return ""
        case .warmUp:  return "W"
        case .dropSet: return "D"
        }
    }
}

enum Equipment: String, Codable, CaseIterable {
    case barbell, dumbbell, cable, machine, bodyweight, kettlebell, band, other
    
    var displayName: String {
        self.rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .barbell: return "barbell"
        case .dumbbell: return "dumbbell"
        case .cable: return "cable.connector"
        case .machine: return "gearshape.2"
        case .bodyweight: return "figure.walk"
        case .kettlebell: return "kettlebell"
        case .band: return "point.topleft.down.curvedto.point.bottomright.up"
        case .other: return "questionmark.circle"
        }
    }
}
