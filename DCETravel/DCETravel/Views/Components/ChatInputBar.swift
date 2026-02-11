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
            .background(DCEColors.warmBackground)
            .cornerRadius(24)

            if !text.isEmpty {
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(DCEColors.navy)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}
