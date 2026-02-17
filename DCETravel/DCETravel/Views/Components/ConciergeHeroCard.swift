import SwiftUI

struct ConciergeHeroCard: View {
    let trip: Trip
    let daysUntil: Int
    let bookingsCount: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Hero image with gradient overlay
                ZStack(alignment: .bottomLeading) {
                    AsyncImage(url: URL(string: trip.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Rectangle()
                                .fill(DCEColors.shimmer)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.system(size: 32))
                                        .foregroundColor(DCEColors.tertiaryText)
                                )
                        default:
                            Rectangle()
                                .fill(DCEColors.shimmer)
                                .overlay(ShimmerView())
                        }
                    }
                    .frame(height: 240)
                    .clipped()

                    // Rich multi-stop gradient (navy-based for dark mode)
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: DCEColors.navy.opacity(0.03), location: 0.25),
                            .init(color: DCEColors.navy.opacity(0.45), location: 0.6),
                            .init(color: DCEColors.navy.opacity(0.92), location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Trip name, dates, countdown
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(trip.name)
                                .font(DCEFonts.displaySmall())
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            Text(trip.dateRangeText)
                                .font(DCEFonts.bodyMedium())
                                .foregroundColor(.white.opacity(0.9))
                        }

                        Spacer()

                        // Frosted countdown pill
                        VStack(spacing: 1) {
                            Text("\(daysUntil)")
                                .font(.system(size: 28, weight: .bold, design: .serif))
                                .foregroundColor(DCEColors.gold)
                            Text("days")
                                .font(DCEFonts.labelSmall())
                                .foregroundColor(DCEColors.secondaryText)
                                .textCase(.uppercase)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(DCEColors.navy.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(DCEColors.gold.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(20)
                }
                .frame(height: 240)

                // Bottom info row
                HStack {
                    // Travelers
                    HStack(spacing: 6) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DCEColors.secondaryText)
                        Text(trip.travelers.prefix(2).joined(separator: ", "))
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.primaryText)
                        if trip.travelers.count > 2 {
                            Text("+\(trip.travelers.count - 2)")
                                .font(DCEFonts.bodySmall())
                                .foregroundColor(DCEColors.tertiaryText)
                        }
                    }

                    Spacer()

                    // Bookings count
                    HStack(spacing: 5) {
                        Image(systemName: bookingsCount > 0 ? "checkmark.circle.fill" : "plus.circle")
                            .font(.system(size: 13))
                            .foregroundColor(bookingsCount > 0 ? DCEColors.success : DCEColors.gold)
                        Text(bookingsCount > 0 ? "\(bookingsCount) booked" : "Start planning")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(bookingsCount > 0 ? DCEColors.primaryText : DCEColors.gold)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(DCEColors.cardBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(DCEColors.glassBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 6)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}
