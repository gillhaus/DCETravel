import SwiftUI

struct ItineraryThemeCards: View {
    let themes: [ItineraryTheme]
    let onSelect: (ItineraryTheme) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(themes) { theme in
                    ItineraryThemeCard(theme: theme) {
                        onSelect(theme)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

struct ItineraryThemeCard: View {
    let theme: ItineraryTheme
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: URL(string: theme.imageURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().aspectRatio(contentMode: .fill)
                        default:
                            Rectangle().fill(DCEColors.shimmer)
                        }
                    }
                    .frame(width: 220, height: 140)
                    .clipped()

                    Text("Based on your interests")
                        .font(DCEFonts.caption())
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.5))
                        .cornerRadius(4)
                        .padding(10)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(theme.title)
                        .font(DCEFonts.headlineSmall())
                        .foregroundColor(DCEColors.primaryText)
                        .lineLimit(2)

                    FlowLayout(spacing: 6) {
                        ForEach(theme.tags, id: \.self) { tag in
                            TagChip(text: tag, style: .highlighted)
                        }
                    }
                }
                .padding(12)
            }
            .frame(width: 220)
            .background(DCEColors.cardBackground)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}
