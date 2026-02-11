import SwiftUI

struct ShimmerView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        LinearGradient(
            colors: [
                DCEColors.shimmer.opacity(0.4),
                DCEColors.shimmer.opacity(0.8),
                DCEColors.shimmer.opacity(0.4)
            ],
            startPoint: .init(x: phase - 1, y: 0.5),
            endPoint: .init(x: phase, y: 0.5)
        )
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var dotOpacities: [Double] = [0.3, 0.3, 0.3]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(DCEColors.secondaryText)
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacities[index])
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(DCEColors.agentBubble)
        .cornerRadius(20)
        .onAppear {
            animateDots()
        }
    }

    private func animateDots() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.2)
            ) {
                dotOpacities[i] = 1.0
            }
        }
    }
}
