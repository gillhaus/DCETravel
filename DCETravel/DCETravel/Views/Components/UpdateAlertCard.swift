import SwiftUI

struct UpdateAlertCard: View {
    let alert: UpdateAlert
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: alert.icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconBackgroundColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(alert.title)
                        .font(DCEFonts.labelLarge())
                        .foregroundColor(DCEColors.primaryText)
                    Text(alert.subtitle)
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }

                Spacer()

                Circle()
                    .fill(dotColor)
                    .frame(width: 10, height: 10)
            }
            .padding(16)
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }

    private var iconBackgroundColor: Color {
        switch alert.type {
        case .urgent: return DCEColors.error
        case .warning: return DCEColors.warning
        case .info: return DCEColors.navy
        }
    }

    private var dotColor: Color {
        switch alert.type {
        case .urgent: return DCEColors.error
        case .warning: return DCEColors.warning
        case .info: return DCEColors.navy
        }
    }
}
