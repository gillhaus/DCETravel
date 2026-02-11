import SwiftUI

struct MiniHotelCard: View {
    let hotel: Hotel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: hotel.imageURLs.first ?? "")) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(DCEColors.shimmer)
                        }
                    }
                    .frame(height: 140)
                    .clipped()

                    if let tier = hotel.tier {
                        Text(tier.rawValue)
                            .font(DCEFonts.labelSmall())
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(DCEColors.copper)
                            .cornerRadius(4)
                            .padding(10)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(hotel.name)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)

                    HStack(spacing: 4) {
                        ForEach(0..<hotel.starRating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(DCEColors.copper)
                        }
                        Text("\u{00B7}")
                        Text("\(hotel.userRating, specifier: "%.1f") Rating")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                    }

                    Text(hotel.locationDetail)
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)

                    HStack {
                        Text("$\(Int(hotel.totalPrice))")
                            .font(DCEFonts.labelLarge())
                            .foregroundColor(DCEColors.primaryText)
                        Text("/")
                            .foregroundColor(DCEColors.tertiaryText)
                        Text("\(hotel.pointsCost.formatted()) pts")
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.copper)
                    }
                }
                .padding(12)
            }
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 260)
    }
}

struct MiniRestaurantCard: View {
    let restaurant: Restaurant
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                AsyncImage(url: URL(string: restaurant.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(DCEColors.shimmer)
                    }
                }
                .frame(height: 120)
                .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)

                    HStack {
                        Text(restaurant.cuisine)
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                        Spacer()
                        if restaurant.isBooked {
                            Label("Booked", systemImage: "checkmark.circle.fill")
                                .font(DCEFonts.labelSmall())
                                .foregroundColor(DCEColors.success)
                        }
                    }

                    if let date = restaurant.reservationDate, let time = restaurant.reservationTime {
                        HStack(spacing: 12) {
                            Label(date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            Label(time, systemImage: "clock")
                            if let guests = restaurant.guestCount {
                                Label("\(guests) guests", systemImage: "person.2")
                            }
                        }
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                    }
                }
                .padding(12)
            }
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 280)
    }
}

struct LoungeMiniCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    Rectangle()
                        .fill(DCEColors.navy.opacity(0.1))
                        .frame(height: 100)
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 32))
                        .foregroundColor(DCEColors.navy)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Prima Vista Lounge")
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)
                    Text("Terminal E \u{00B7} Priority Pass")
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)

                    Label("Booked", systemImage: "checkmark.circle.fill")
                        .font(DCEFonts.labelSmall())
                        .foregroundColor(DCEColors.success)
                }
                .padding(12)
            }
            .background(DCEColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 240)
    }
}
