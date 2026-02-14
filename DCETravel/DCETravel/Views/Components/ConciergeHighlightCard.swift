import SwiftUI

struct ConciergeHighlightCard: View {
    let variant: Variant
    let onTap: () -> Void

    enum Variant {
        case nextBooking(booking: Booking)
        case aiSuggestion(title: String, subtitle: String)
        case pointsSummary(balance: String, tier: String, value: String)
    }

    private var accentColor: Color {
        switch variant {
        case .nextBooking: return DCEColors.success
        case .aiSuggestion: return Color(hex: "7C3AED")  // purple
        case .pointsSummary: return DCEColors.pointsBoostAccent
        }
    }

    private var icon: String {
        switch variant {
        case .nextBooking(let booking):
            switch booking.type {
            case .flight: return "airplane"
            case .hotel: return "building.2"
            case .restaurant: return "fork.knife"
            case .carRental: return "car.fill"
            case .lounge: return "cup.and.saucer.fill"
            case .activity: return "ticket"
            }
        case .aiSuggestion: return "sparkles"
        case .pointsSummary: return "star.circle.fill"
        }
    }

    private var title: String {
        switch variant {
        case .nextBooking(let booking):
            return "\(booking.type.rawValue) Confirmed"
        case .aiSuggestion(let title, _):
            return title
        case .pointsSummary(let balance, _, _):
            return "\(balance) pts"
        }
    }

    private var subtitle: String {
        switch variant {
        case .nextBooking(let booking):
            return "\(booking.details) \u{00B7} \(booking.confirmationNumber)"
        case .aiSuggestion(_, let subtitle):
            return subtitle
        case .pointsSummary(_, let tier, let value):
            return "\(tier) \u{00B7} ~\(value)"
        }
    }

    private var actionLabel: String {
        switch variant {
        case .nextBooking: return "View booking"
        case .aiSuggestion: return "Ask more"
        case .pointsSummary: return "View rewards"
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Accent bar
                UnevenRoundedRectangle(
                    topLeadingRadius: 2,
                    bottomLeadingRadius: 2,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
                .fill(
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)

                HStack(spacing: 14) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                        .frame(width: 40, height: 40)
                        .background(accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Text
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(DCEFonts.headlineSmall())
                            .foregroundColor(DCEColors.primaryText)
                            .lineLimit(1)
                        Text(subtitle)
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.secondaryText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 4)

                    // Action chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(DCEColors.tertiaryText)
                        .frame(width: 28, height: 28)
                        .background(DCEColors.warmBackground)
                        .clipShape(Circle())
                }
                .padding(.leading, 14)
                .padding(.trailing, 12)
                .padding(.vertical, 16)
            }
            .background(DCEColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: DCEColors.navy.opacity(0.06), radius: 8, x: 0, y: 3)
            .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}
