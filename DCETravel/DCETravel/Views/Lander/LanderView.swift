import SwiftUI

struct LanderView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: AppRouter
    @State private var animateContent = false
    @State private var promptText = ""

    var body: some View {
        ZStack {
            DCEColors.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo section
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "diamond.fill")
                            .font(.system(size: 28))
                            .foregroundColor(DCEColors.navy)
                        Text("Travel")
                            .font(DCEFonts.displayLarge())
                            .foregroundColor(DCEColors.navy)
                    }
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)

                    VStack(spacing: 8) {
                        Text("Hi \(appState.currentUser.firstName),")
                            .font(DCEFonts.displaySmall())
                            .foregroundColor(DCEColors.primaryText)
                        Text("I'm your Travel Concierge.")
                            .font(DCEFonts.displaySmall())
                            .foregroundColor(DCEColors.primaryText)
                        Text("Powered by DCE Travel AI")
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.secondaryText)
                            .padding(.top, 4)
                    }
                    .multilineTextAlignment(.center)
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 20)
                }
                .padding(.bottom, 32)

                // Hero image
                ZStack {
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800")) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        default:
                            Rectangle()
                                .fill(DCEColors.shimmer)
                                .overlay(ShimmerView())
                        }
                    }
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(24)
                    .padding(.horizontal, 24)

                    // Floating prompt chip
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "sparkles")
                                .foregroundColor(DCEColors.copper)
                            Text("Create an itinerary in Spain for 2")
                                .font(DCEFonts.labelMedium())
                                .foregroundColor(DCEColors.primaryText)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .offset(y: 20)
                    }
                    .padding(.horizontal, 40)
                }
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.95)

                Spacer()

                // CTA button
                VStack(spacing: 16) {
                    Button {
                        router.navigate(to: .home)
                    } label: {
                        Text("See what I can do")
                    }
                    .buttonStyle(DCEPrimaryButtonStyle())
                    .padding(.horizontal, 24)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 30)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animateContent = true
            }
            Task {
                await appState.loadInitialData()
            }
        }
    }
}

#Preview {
    NavigationStack {
        LanderView()
            .environmentObject(AppState())
            .environmentObject(AppRouter())
    }
}
