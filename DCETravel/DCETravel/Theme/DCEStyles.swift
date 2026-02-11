import SwiftUI

// MARK: - Button Styles

struct DCEPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(DCEColors.navy)
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
            .foregroundColor(DCEColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DCEColors.navy, lineWidth: 1.5)
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
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(DCEColors.copper)
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
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
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
            .background(isSelected ? DCEColors.navy : DCEColors.warmBackground)
            .foregroundColor(isSelected ? .white : DCEColors.primaryText)
            .cornerRadius(20)
    }
}

extension View {
    func dceChip(isSelected: Bool = false) -> some View {
        modifier(DCEChipStyle(isSelected: isSelected))
    }
}
