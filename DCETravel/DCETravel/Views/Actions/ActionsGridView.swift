import SwiftUI

struct ActionsGridView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var chatText = ""

    private struct GridAction: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let chatMessage: String?
        let route: AppRoute?
    }

    private let actions: [GridAction] = [
        GridAction(icon: "airplane", title: "Trip suggestions", chatMessage: nil, route: .tripSuggestions),
        GridAction(icon: "star.circle", title: "Maximize points", chatMessage: "How can I maximize my points?", route: nil),
        GridAction(icon: "shield.checkered", title: "Benefits", chatMessage: "What are my Sapphire Reserve benefits?", route: nil),
        GridAction(icon: "briefcase", title: "Trip services", chatMessage: "What trip services are available?", route: nil),
        GridAction(icon: "ticket", title: "Find events", chatMessage: "Find events and activities for my trip", route: nil),
        GridAction(icon: "fork.knife", title: "Book restaurants", chatMessage: "Help me find and book restaurants", route: nil),
        GridAction(icon: "list.clipboard", title: "Manage bookings", chatMessage: "Show me my current bookings", route: nil),
        GridAction(icon: "globe.americas", title: "Book trips", chatMessage: nil, route: .tripSuggestions)
    ]

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("See what I can do")
                    .font(DCEFonts.displayMedium())
                    .foregroundColor(DCEColors.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                // Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(actions) { action in
                            ActionTile(icon: action.icon, title: action.title) {
                                handleAction(action)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)
                }

                Spacer()
            }

            // Bottom chat bar
            VStack {
                Spacer()
                ChatInputBar(
                    text: $chatText,
                    onSend: { sendMessage() },
                    onCamera: {},
                    onMic: {}
                )
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func handleAction(_ action: GridAction) {
        if let route = action.route {
            router.navigate(to: route)
        } else if let chatMessage = action.chatMessage, let trip = appState.activeTrips.first {
            appState.pendingChatAction = chatMessage
            router.navigate(to: .chat(tripId: trip.id))
        }
    }

    private func sendMessage() {
        guard !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        if let trip = appState.activeTrips.first {
            appState.pendingChatAction = chatText
            router.navigate(to: .chat(tripId: trip.id))
        }
        chatText = ""
    }
}

struct ActionTile: View {
    let icon: String
    let title: String
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(DCEColors.navy.opacity(0.08))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(DCEColors.navy)
                }

                Text(title)
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ActionsGridView()
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
