import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void
    let onCamera: (() -> Void)?
    let onMic: (() -> Void)?

    init(
        text: Binding<String>,
        placeholder: String = "Ask away, and elevate any trip",
        onSend: @escaping () -> Void,
        onCamera: (() -> Void)? = nil,
        onMic: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSend = onSend
        self.onCamera = onCamera
        self.onMic = onMic
    }

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .font(DCEFonts.bodyMedium())
                    .foregroundColor(DCEColors.primaryText)

                if let onCamera = onCamera {
                    Button(action: onCamera) {
                        Image(systemName: "camera")
                            .font(.system(size: 18))
                            .foregroundColor(DCEColors.secondaryText)
                    }
                }

                if let onMic = onMic {
                    Button(action: onMic) {
                        Image(systemName: "mic")
                            .font(.system(size: 18))
                            .foregroundColor(DCEColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DCEColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DCEColors.glassBorder, lineWidth: 1)
            )
            .cornerRadius(24)

            if !text.isEmpty {
                Button(action: onSend) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [DCEColors.gold, DCEColors.copper],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 36, height: 36)
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DCEColors.navy)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(DCEColors.warmBackground.opacity(0.95))
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}
