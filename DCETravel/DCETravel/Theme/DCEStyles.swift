import SwiftUI

// MARK: - Button Styles

struct DCEPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [DCEColors.gold, DCEColors.copper],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DCESecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DCEColors.gold.opacity(0.4), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DCECopperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [DCEColors.gold, DCEColors.copper],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Card Modifier

struct DCECardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DCEColors.glassBorder, lineWidth: 1)
            )
    }
}

extension View {
    func dceCard(padding: CGFloat = 16) -> some View {
        modifier(DCECardModifier(padding: padding))
    }
}

// MARK: - Chip Style

struct DCEChipStyle: ViewModifier {
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .font(DCEFonts.labelMedium())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? DCEColors.gold.opacity(0.2) : DCEColors.glass)
            .foregroundColor(isSelected ? DCEColors.gold : DCEColors.secondaryText)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? DCEColors.gold.opacity(0.3) : DCEColors.glassBorder, lineWidth: 1)
            )
    }
}

extension View {
    func dceChip(isSelected: Bool = false) -> some View {
        modifier(DCEChipStyle(isSelected: isSelected))
    }
}
