import SwiftUI

struct QuickActionChip: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(DCEFonts.labelMedium())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(DCEColors.warmBackground)
            .foregroundColor(DCEColors.primaryText)
            .cornerRadius(20)
        }
    }
}

struct QuickActionChipsRow: View {
    let actions: [(title: String, icon: String)]
    let onTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(actions, id: \.title) { action in
                    QuickActionChip(title: action.title, icon: action.icon) {
                        onTap(action.title)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}
