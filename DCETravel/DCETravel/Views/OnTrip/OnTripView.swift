import SwiftUI

struct OnTripView: View {
    let tripId: UUID
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Pre-loaded on-trip messages
                            ForEach(viewModel.messages) { message in
                                ChatBubble(message: message) { action in
                                    handleItemAction(action)
                                }
                                .id(message.id)
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

                // Trip bar
                TripItineraryBar(trip: currentTrip) {
                    // Expand itinerary
                }

                // Input bar
                ChatInputBar(
                    text: $inputText,
                    onSend: { sendMessage() },
                    onCamera: {},
                    onMic: {}
                )
            }
        }
        .navigationTitle(currentTrip?.name ?? "On Trip")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    router.navigate(to: .postTrip)
                } label: {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(DCEColors.navy)
                }
            }
        }
        .task {
            await loadOnTripMessages()
        }
    }

    private var currentTrip: Trip? {
        appState.activeTrips.first { $0.id == tripId }
    }

    private func loadOnTripMessages() async {
        await viewModel.loadChat(tripId: tripId, services: appState.services)

        // Add on-trip specific messages
        try? await Task.sleep(nanoseconds: 500_000_000)

        let restaurantMessage = ChatMessage(
            id: UUID(),
            sender: .agent,
            text: "I checked restaurant availability for your group tonight. Great news — I was able to book a table at one of Rome's best-loved trattorias!",
            timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .restaurantCard,
                restaurant: MockData.restaurants[0]
            )
        )

        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.messages.append(restaurantMessage)
        }

        try? await Task.sleep(nanoseconds: 1_000_000_000)

        let loungeMessage = ChatMessage(
            id: UUID(),
            sender: .agent,
            text: "For your departure, I've arranged access to the Prima Vista Lounge in Terminal E. As a Sapphire Reserve member, you and your guests can enjoy complimentary refreshments and a quiet space before your flight.",
            timestamp: Date(),
            richContent: ChatMessage.RichContent(
                type: .loungeCard,
                imageURL: "https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800"
            )
        )

        withAnimation(.easeInOut(duration: 0.3)) {
            viewModel.messages.append(loungeMessage)
        }
    }

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = inputText
        inputText = ""
        Task {
            await viewModel.sendMessage(text, tripId: tripId)
        }
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

#Preview {
    NavigationStack {
        OnTripView(tripId: UUID())
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
