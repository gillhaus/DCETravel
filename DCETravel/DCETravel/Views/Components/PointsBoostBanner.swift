import SwiftUI

struct PointsBoostBanner: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14))
                .foregroundColor(DCEColors.pointsBoostAccent)
            Text("Points Boost applied")
                .font(DCEFonts.labelMedium())
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DCEColors.pointsBoostBackground)
    }
}
