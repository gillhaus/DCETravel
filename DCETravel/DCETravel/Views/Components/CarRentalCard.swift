import SwiftUI

struct CarRentalCard: View {
    let car: CarRental
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: car.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(DCEColors.shimmer)
                                .overlay(
                                    Image(systemName: "car.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(DCEColors.tertiaryText)
                                )
                        }
                    }
                    .frame(height: 120)
                    .clipped()

                    Text(car.carType.rawValue)
                        .font(DCEFonts.labelSmall())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(DCEColors.navy)
                        .cornerRadius(4)
                        .padding(10)
                }

                // Details
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "car.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DCEColors.navy)
                        Text(car.company)
                            .font(DCEFonts.labelMedium())
                            .foregroundColor(DCEColors.secondaryText)
                    }

                    Text(car.model)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)

                    HStack(spacing: 4) {
                        Text("Automatic")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                        Text("\u{00B7}")
                            .foregroundColor(DCEColors.tertiaryText)
                        Text("\(car.seating) seats")
                            .font(DCEFonts.caption())
                            .foregroundColor(DCEColors.secondaryText)
                    }

                    HStack {
                        Text("$\(Int(car.pricePerDay))/day")
                            .font(DCEFonts.labelLarge())
                            .foregroundColor(DCEColors.primaryText)
                        Spacer()
                        Text("\(car.pointsCost.formatted()) pts")
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
