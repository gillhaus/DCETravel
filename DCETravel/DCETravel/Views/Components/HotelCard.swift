import SwiftUI

struct HotelCard: View {
    let hotel: Hotel
    let nightCount: Int
    let showPointsBoost: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Points Boost Banner
                if showPointsBoost {
                    PointsBoostBanner()
                }

                // Hotel Image
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: hotel.imageURLs.first ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(DCEColors.shimmer)
                        }
                    }
                    .frame(height: 200)
                    .clipped()

                    if let tier = hotel.tier {
                        Text(tier.rawValue)
                            .font(DCEFonts.labelSmall())
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(DCEColors.copper)
                            .cornerRadius(4)
                            .padding(12)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DCEColors.success)
                            .font(.system(size: 18))
                        Text("Hotel in Rome - \(nightCount) night stay")
                            .font(DCEFonts.labelLarge())
                            .foregroundColor(DCEColors.primaryText)
                    }

                    Text(hotel.name)
                        .font(DCEFonts.headlineMedium())
                        .foregroundColor(DCEColors.primaryText)

                    HStack(spacing: 4) {
                        ForEach(0..<hotel.starRating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(DCEColors.copper)
                        }
                        Text("\u{00B7}")
                            .foregroundColor(DCEColors.tertiaryText)
                        Text("\(hotel.userRating, specifier: "%.0f")/5 Rating")
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.secondaryText)
                    }

                    Text(hotel.locationDetail)
                        .font(DCEFonts.bodySmall())
                        .dceChip()

                    Divider()

                    // Price section
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("$\(Int(hotel.totalPrice))")
                                .font(DCEFonts.headlineLarge())
                                .foregroundColor(DCEColors.primaryText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(hotel.pointsCost.formatted()) pts")
                                .font(DCEFonts.headlineSmall())
                                .foregroundColor(DCEColors.copper)
                            if hotel.originalPointsCost > hotel.pointsCost {
                                Text("\(hotel.originalPointsCost.formatted()) pts")
                                    .font(DCEFonts.caption())
                                    .foregroundColor(DCEColors.tertiaryText)
                                    .strikethrough()
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}
