import SwiftUI

enum GymFont {
    case largeTitle
    case title
    case body
    case caption
    case mono
    
    var font: Font {
        switch self {
        case .largeTitle:
            return .system(size: 34, weight: .bold)
        case .title:
            return .system(size: 22, weight: .bold)
        case .body:
            return .system(size: 17, weight: .regular)
        case .caption:
            return .system(size: 13, weight: .regular)
        case .mono:
            return .system(size: 17, weight: .regular, design: .monospaced)
        }
    }
}

struct GymFontModifier: ViewModifier {
    let gymFont: GymFont
    
    func body(content: Content) -> some View {
        content.font(gymFont.font)
    }
}

extension View {
    func gymFont(_ gymFont: GymFont) -> some View {
        self.modifier(GymFontModifier(gymFont: gymFont))
    }
}
