import SwiftUI

struct ChatView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @State private var showItineraryBar = false
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message) { action in
                                    handleItemAction(action)
                                }
                                .id(message.id)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                                    removal: .opacity
                                ))
                            }

                            if viewModel.isTyping {
                                HStack(alignment: .top, spacing: 8) {
                                    ZStack {
                                        Circle()
                                            .fill(DCEColors.navy)
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14))
                                            .foregroundColor(.white)
                                    }
                                    TypingIndicator()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }

                // Suggested actions
                if !viewModel.suggestedActions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.suggestedActions, id: \.self) { action in
                                Button {
                                    handlePillTap(action)
                                } label: {
                                    Text(action)
                                        .font(DCEFonts.labelSmall())
                                        .foregroundColor(DCEColors.navy)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(DCEColors.navy.opacity(0.08))
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }

                // Input bar
                ChatInputBar(
                    text: $inputText,
                    onSend: { sendMessage() },
                    onCamera: {},
                    onMic: {}
                )
            }

            // Trip itinerary bar (on-trip)
            if showItineraryBar {
                VStack {
                    Spacer()
                    TripItineraryBar(trip: currentTrip) {
                        // Expand itinerary
                    }
                    .padding(.bottom, 70)
                }
            }
        }
        .navigationTitle(currentTrip?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("View Itinerary") {
                        // Show itinerary
                    }
                    Button("Checkout") {
                        router.navigate(to: .checkout(tripId: tripId))
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
        .onChange(of: viewModel.pendingNavigation) { _, newValue in
            if let route = newValue {
                viewModel.pendingNavigation = nil
                // Small delay so the message is visible first
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    router.navigate(to: route)
                }
            }
        }
        .task {
            let pending = appState.pendingChatAction
            appState.pendingChatAction = nil
            await viewModel.loadChat(tripId: tripId, services: appState.services, appState: appState, pendingAction: pending)
        }
    }

    private var currentTrip: Trip? {
        appState.activeTrips.first { $0.id == tripId }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = inputText
        inputText = ""
        Task {
            await viewModel.sendMessage(text, tripId: tripId)
        }
    }

    private func handlePillTap(_ pill: String) {
        if let category = categoryForAction(pill) {
            router.navigate(to: .searchResults(tripId: tripId, category: category))
        } else {
            inputText = pill
            sendMessage()
        }
    }

    private func categoryForAction(_ action: String) -> SearchCategory? {
        let lower = action.lowercased()
        if lower.contains("flight") { return .flights }
        if lower.contains("hotel") { return .hotels }
        if lower.contains("car") || lower.contains("rent") { return .cars }
        if lower.contains("restaurant") || lower.contains("dining") { return .restaurants }
        if lower.contains("point") || lower.contains("balance") || lower.contains("reward") { return .points }
        if lower.contains("booking") { return .bookings }
        if lower.contains("destination") { return .destinations }
        return nil
    }

    private func handleItemAction(_ action: ChatItemAction) {
        switch action {
        case .bookFlight(let flight):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .flight(flight)))
        case .bookHotel(let hotel):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .hotel(hotel)))
        case .bookRestaurant(let restaurant):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .restaurant(restaurant)))
        case .bookCar(let car):
            router.navigate(to: .itemCheckout(tripId: tripId, item: .carRental(car)))
        case .exploreDest(let dest):
            inputText = "Search flights and hotels for \(dest.name)"
            sendMessage()
        case .selectTheme(let theme):
            inputText = "Plan a \(theme.title) trip"
            sendMessage()
        case .viewBooking(let booking):
            inputText = "Tell me about booking \(booking.confirmationNumber)"
            sendMessage()
        case .viewLounge:
            inputText = "Tell me about lounge access"
            sendMessage()
        case .viewConfirmation:
            router.navigate(to: .confirmation(tripId: tripId))
        }
    }
}

// MARK: - Trip Itinerary Bar
struct TripItineraryBar: View {
    let trip: Trip?
    let onExpand: () -> Void

    var body: some View {
        if let trip = trip {
            Button(action: onExpand) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.destination)
                            .font(DCEFonts.labelLarge())
                            .foregroundColor(.white)
                        Text(trip.dateRangeText)
                            .font(DCEFonts.caption())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "chevron.up")
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(DCEColors.navy)
                .cornerRadius(16)
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
