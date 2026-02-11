import SwiftUI

struct DestinationCard: View {
    let destination: Destination
    var width: CGFloat = 200
    var height: CGFloat = 260
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: URL(string: destination.imageURL)) { phase in
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
                                    .foregroundColor(DCEColors.tertiaryText)
                            )
                    default:
                        Rectangle()
                            .fill(DCEColors.shimmer)
                            .overlay(ShimmerView())
                    }
                }
                .frame(width: width, height: height)
                .clipped()

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    if let category = destination.category.rawValue as String? {
                        Text(category)
                            .font(DCEFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Text(destination.name)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(.white)
                    if let dates = destination.suggestedDates {
                        Text(dates)
                            .font(DCEFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(16)
            }
            .frame(width: width, height: height)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}
