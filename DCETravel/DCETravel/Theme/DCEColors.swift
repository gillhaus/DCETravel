import SwiftUI

enum DCEColors {
    // Primary
    static let navy = Color(hex: "0A1628")
    static let copper = Color(hex: "C26A2F")

    // Gold accent system
    static let gold = Color(hex: "C9A96E")
    static let goldLight = Color(hex: "D4B87A")
    static let goldDim = Color(hex: "C9A96E").opacity(0.15)

    // Backgrounds
    static let warmBackground = Color(hex: "0A1628")
    static let creamBackground = Color(hex: "0F1D32")
    static let cardBackground = Color(hex: "14243D")
    static let cardBackgroundElevated = Color(hex: "1A2B4A")

    // Glass-morphism
    static let glass = Color.white.opacity(0.04)
    static let glassBorder = Color.white.opacity(0.08)

    // Chat
    static let agentBubble = Color(hex: "14243D")
    static let userBubble = Color(hex: "1A2B4A")

    // Status
    static let success = Color(hex: "3DD68C")
    static let warning = Color(hex: "F5A623")
    static let error = Color(hex: "E85454")

    // Text
    static let primaryText = Color(hex: "F0EDE8")
    static let secondaryText = Color(hex: "8B9BB4")
    static let tertiaryText = Color(hex: "5A6A82")

    // Points
    static let pointsBoostBackground = Color(hex: "14243D")
    static let pointsBoostAccent = Color(hex: "C9A96E")

    // Misc
    static let divider = Color.white.opacity(0.06)
    static let shimmer = Color(hex: "1A2B4A")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
