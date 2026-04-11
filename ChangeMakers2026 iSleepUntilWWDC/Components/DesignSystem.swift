import SwiftUI

enum Theme {
    static let primary = Color.red
    static let secondary = Color.black
    static let dicePrim = Color.white
    static let diceSec = Color.orange
    static let cardBorder = Color.white.opacity(0.1)
    static let cardBackground = Color.white.opacity(0.15)
    
    static let cornerRadius: CGFloat = 15
    
    enum Quest {
        static let learning = Color.blue
        static let roleplay = Color.purple
        static let forge = Color.orange
    }
}

struct SquareFiller: ViewModifier {
    var isPrimary: Bool = false
    var primaryColor: Color = .clear
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(
                        isPrimary ? primaryColor : Theme.cardBorder,
                        lineWidth: isPrimary ? 2 : 1
                    )
            )
    }
}

extension View {
    func glassCard(isPrimary: Bool = false, primaryColor: Color = .clear) -> some View {
        self.modifier(SquareFiller(isPrimary: isPrimary, primaryColor: primaryColor))
    }
}
