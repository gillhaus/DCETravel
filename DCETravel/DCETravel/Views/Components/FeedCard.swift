import SwiftUI

struct FeedCard: View {
    let item: FeedItem
    let onAction: (FeedItem.FeedAction) -> Void

    var body: some View {
        Button {
            if let action = item.action {
                onAction(action)
            }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                // Icon circle with accent color
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: item.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(accentColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    // Type label
                    Text(typeLabel)
                        .font(DCEFonts.caption())
                        .foregroundColor(accentColor)
                        .textCase(.uppercase)
                        .tracking(0.5)

                    // Title
                    Text(item.title)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)
                        .multilineTextAlignment(.leading)

                    // Subtitle
                    Text(item.subtitle)
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)

                    // Action button (type-specific)
                    if let buttonInfo = actionButtonInfo {
                        HStack(spacing: 4) {
                            Text(buttonInfo.label)
                                .font(DCEFonts.labelMedium())
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(accentColor)
                        .padding(.top, 4)
                    }
                }

                Spacer(minLength: 0)

                // Timestamp
                Text(timeAgoText)
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.tertiaryText)
            }
            .padding(16)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(accentColor.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Accent Colors

    private var accentColor: Color {
        switch item.type {
        case .tripUpdate:
            return DCEColors.navy
        case .aiSuggestion:
            return Color(hex: "8B5CF6") // purple
        case .bookingAlert:
            return DCEColors.success
        case .priceAlert:
            return Color(hex: "EA580C") // orange
        case .pointsUpdate:
            return Color(hex: "D97706") // amber/gold
        case .weatherAlert:
            return Color(hex: "2563EB") // blue
        case .inspiration:
            return Color(hex: "0D9488") // teal
        }
    }

    // MARK: - Type Label

    private var typeLabel: String {
        switch item.type {
        case .tripUpdate: return "Trip Update"
        case .aiSuggestion: return "AI Suggestion"
        case .bookingAlert: return "Booking"
        case .priceAlert: return "Price Alert"
        case .pointsUpdate: return "Points & Rewards"
        case .weatherAlert: return "Weather"
        case .inspiration: return "Inspiration"
        }
    }

    // MARK: - Action Button

    private struct ActionButton {
        let label: String
    }

    private var actionButtonInfo: ActionButton? {
        switch item.type {
        case .tripUpdate:
            return ActionButton(label: "View Trip")
        case .aiSuggestion:
            return ActionButton(label: "Ask More")
        case .priceAlert:
            return ActionButton(label: "View Deal")
        case .pointsUpdate:
            return ActionButton(label: "View Rewards")
        case .weatherAlert:
            return ActionButton(label: "Trip Details")
        case .bookingAlert:
            return nil // tap card to navigate
        case .inspiration:
            return ActionButton(label: "Explore")
        }
    }

    // MARK: - Time Formatting

    private var timeAgoText: String {
        let interval = Date().timeIntervalSince(item.timestamp)
        let minutes = Int(interval / 60)

        if minutes < 1 {
            return "Now"
        } else if minutes < 60 {
            return "\(minutes)m"
        } else if minutes < 1440 {
            return "\(minutes / 60)h"
        } else {
            return "\(minutes / 1440)d"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        FeedCard(
            item: FeedItem(
                id: UUID(),
                type: .tripUpdate,
                timestamp: Date(),
                title: "Girl's trip to Rome",
                subtitle: "Rome is 45 days away \u{2022} Sep 23 - Sep 29",
                icon: "calendar.badge.clock",
                action: nil
            ),
            onAction: { _ in }
        )

        FeedCard(
            item: FeedItem(
                id: UUID(),
                type: .aiSuggestion,
                timestamp: Date().addingTimeInterval(-3600),
                title: "Restaurant Picks Near Your Hotel",
                subtitle: "I found 3 highly-rated trattorias within walking distance of your stay in Rome.",
                icon: "sparkles",
                action: nil
            ),
            onAction: { _ in }
        )

        FeedCard(
            item: FeedItem(
                id: UUID(),
                type: .priceAlert,
                timestamp: Date().addingTimeInterval(-7200),
                title: "Hotel Prices Dropped in Rome",
                subtitle: "Luxury hotel rates dropped 12% for your dates. Save up to $680.",
                icon: "tag.fill",
                action: nil
            ),
            onAction: { _ in }
        )
    }
    .padding()
    .background(DCEColors.warmBackground)
}
