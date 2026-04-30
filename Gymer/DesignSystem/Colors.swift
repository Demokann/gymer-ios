import SwiftUI

extension Color {
    // Backgrounds
    static let gymBlack   = Color(hex: "#0D0D0D")  // primary background
    static let gymSurface = Color(hex: "#1A1A1A")  // card background
    static let gymCard    = Color(hex: "#222222")  // elevated card

    // Accents
    static let gymLime    = Color(hex: "#C6FF00")  // primary accent — active states, CTAs
    static let gymRed     = Color(hex: "#FF3B30")  // danger, failure, drop set
    static let gymAmber   = Color(hex: "#FF9F0A")  // warm-up, secondary accent

    // Text
    static let gymWhite   = Color(hex: "#F5F5F5")  // primary text
    static let gymMuted   = Color(hex: "#6B6B6B")  // secondary text
    static let gymBorder  = Color(hex: "#2C2C2C")  // dividers and borders
}

// Hex initializer for Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
