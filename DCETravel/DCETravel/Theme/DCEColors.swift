import SwiftUI

enum DCEColors {
    // Primary
    static let navy = Color(hex: "1A2B4A")
    static let copper = Color(hex: "C26A2F")

    // Backgrounds
    static let warmBackground = Color(hex: "F8F6F3")
    static let creamBackground = Color(hex: "F5F0EA")
    static let cardBackground = Color.white

    // Chat
    static let agentBubble = Color(hex: "F5F0EA")
    static let userBubble = Color.white

    // Status
    static let success = Color(hex: "2D8B4E")
    static let warning = Color(hex: "E8A317")
    static let error = Color(hex: "D64045")

    // Text
    static let primaryText = Color(hex: "1A2B4A")
    static let secondaryText = Color(hex: "6B7280")
    static let tertiaryText = Color(hex: "9CA3AF")

    // Points
    static let pointsBoostBackground = Color(hex: "1A2B4A")
    static let pointsBoostAccent = Color(hex: "C9A96E")

    // Misc
    static let divider = Color(hex: "E5E7EB")
    static let shimmer = Color(hex: "E8E4DF")
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
