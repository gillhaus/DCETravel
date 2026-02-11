import SwiftUI

struct TripProgressCard: View {
    let trip: Trip
    let onReview: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: trip.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Rectangle().fill(DCEColors.shimmer)
                    }
                }
                .frame(height: 160)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(DCEFonts.headlineMedium())
                        .foregroundColor(.white)
                    Text(trip.dateRangeText)
                        .font(DCEFonts.caption())
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(16)
            }

            // Bottom section
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(trip.status.rawValue)
                        .font(DCEFonts.labelSmall())
                        .foregroundColor(statusColor)
                    Text("\(trip.travelers.count) travelers")
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }

                Spacer()

                Button("Review", action: onReview)
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.navy)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(DCEColors.navy, lineWidth: 1)
                    )
            }
            .padding(16)
        }
        .background(DCEColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private var statusColor: Color {
        switch trip.status {
        case .planning: return DCEColors.warning
        case .booked: return DCEColors.success
        case .active: return DCEColors.copper
        case .completed: return DCEColors.secondaryText
        }
    }
}
