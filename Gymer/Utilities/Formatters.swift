// MARK: - Formatters
// Owner: Backend Dev Agent
// Last Modified: 28.04.2026
// Depends on: None

import Foundation

enum Formatters {
    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    static func formatWeight(_ kg: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        
        let formatted = formatter.string(from: NSNumber(value: kg)) ?? "\(kg)"
        return "\(formatted) kg"
    }

    static func weight(_ kg: Double) -> String {
        return formatWeight(kg)
    }
    
    static func formatVolume(_ kg: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        let formatted = formatter.string(from: NSNumber(value: kg)) ?? "\(Int(kg))"
        return "\(formatted) kg"
    }
    
    static func formatRestTimer(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
