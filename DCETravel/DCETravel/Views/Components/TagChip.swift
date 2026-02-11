import SwiftUI

struct TagChip: View {
    let text: String
    var style: TagStyle = .default

    enum TagStyle {
        case `default`
        case highlighted
        case outline
    }

    var body: some View {
        Text(text)
            .font(DCEFonts.labelSmall())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return DCEColors.warmBackground
        case .highlighted: return DCEColors.navy.opacity(0.1)
        case .outline: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default: return DCEColors.secondaryText
        case .highlighted: return DCEColors.navy
        case .outline: return DCEColors.secondaryText
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline: return DCEColors.divider
        default: return .clear
        }
    }
}
