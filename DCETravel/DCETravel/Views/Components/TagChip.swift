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
                    .stroke(borderColor, lineWidth: style == .highlighted ? 0 : 1)
            )
    }

    private var backgroundColor: Color {
        switch style {
        case .default: return DCEColors.glass
        case .highlighted: return DCEColors.goldDim
        case .outline: return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default: return DCEColors.secondaryText
        case .highlighted: return DCEColors.gold
        case .outline: return DCEColors.secondaryText
        }
    }

    private var borderColor: Color {
        switch style {
        case .outline: return DCEColors.glassBorder
        case .default: return DCEColors.glassBorder
        case .highlighted: return .clear
        }
    }
}
