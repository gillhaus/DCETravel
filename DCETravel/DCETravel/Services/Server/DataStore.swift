import Foundation

class DataStore {
    static let shared = DataStore()

    private let lock = NSLock()

    private(set) var destinations: [Destination]
    private(set) var trips: [Trip]
    private(set) var hotels: [Hotel]
    private(set) var flights: [Flight]
    private(set) var restaurants: [Restaurant]
    private(set) var carRentals: [CarRental]
    private(set) var bookings: [Booking]
    private(set) var user: User
    private(set) var itineraryThemes: [ItineraryTheme]

    init() {
        // Initialize with empty arrays, then populate via helpers
        destinations = []
        trips = []
        hotels = []
        flights = []
        restaurants = []
        carRentals = []
        bookings = []
        user = User(
            id: UUID(),
            firstName: "Victoria", lastName: "Chen",
            email: "victoria@example.com",
            pointsBalance: 2_450_000,
            membershipTier: .reserve,
            preferences: TravelPreferences(
                preferredAirlines: ["United", "Delta"],
                preferredHotelChains: ["Marriott", "Four Seasons"],
                dietaryRestrictions: [],
                seatPreference: "Window",
                interests: ["History", "Fine Dining", "Art", "Architecture"]
            ),
            tripHistory: []
        )
        itineraryThemes = []

        seedDestinations()
        seedTripsAndBookings()
        seedHotels()
        seedFlights()
        seedRestaurants()
        seedCarRentals()
        seedItineraryThemes()
    }

    // MARK: - Seed Destinations (12+)

    private func seedDestinations() {
        destinations = [
            Destination(id: UUID(), name: "Tokyo", country: "Japan",
                       imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800",
                       tags: ["Culture", "Food", "Modern"],
                       description: "A fascinating blend of ancient traditions and cutting-edge technology.",
                       suggestedDates: "Mar 15 - Mar 25", category: .trending),
            Destination(id: UUID(), name: "Los Angeles", country: "USA",
                       imageURL: "https://images.unsplash.com/photo-1534190760961-74e8c1c5c3da?w=800",
                       tags: ["Beach", "Entertainment", "Food"],
                       description: "Sun-soaked beaches, world-class dining, and endless entertainment.",
                       suggestedDates: "Apr 5 - Apr 12", category: .trending),
            Destination(id: UUID(), name: "Paris", country: "France",
                       imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800",
                       tags: ["Romance", "Art", "Food"],
                       description: "The City of Light offers unparalleled art, cuisine, and charm.",
                       suggestedDates: "May 1 - May 8", category: .inspiration),
            Destination(id: UUID(), name: "Cairo", country: "Egypt",
                       imageURL: "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=800",
                       tags: ["Ancient history", "Culture", "Adventure"],
                       description: "Explore millennia of history from the Pyramids to bustling bazaars.",
                       suggestedDates: "Mar 23 - Apr 4", category: .recommended),
            Destination(id: UUID(), name: "Bali", country: "Indonesia",
                       imageURL: "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800",
                       tags: ["Relaxation", "Temples", "Nature"],
                       description: "Tropical paradise with ancient temples, rice terraces, and stunning beaches.",
                       suggestedDates: nil, category: .inspiration),
            Destination(id: UUID(), name: "Barcelona", country: "Spain",
                       imageURL: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800",
                       tags: ["Architecture", "Beach", "Nightlife"],
                       description: "Gaudi's masterpieces, Mediterranean beaches, and vibrant culture.",
                       suggestedDates: "Jun 10 - Jun 17", category: .popular),
            Destination(id: UUID(), name: "Rome", country: "Italy",
                       imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800",
                       tags: ["History", "Art", "Food"],
                       description: "The Eternal City — ancient ruins, Renaissance art, and world-class cuisine.",
                       suggestedDates: "Sep 23 - Sep 29", category: .popular),
            Destination(id: UUID(), name: "Reykjavik", country: "Iceland",
                       imageURL: "https://images.unsplash.com/photo-1504829857797-ddff29c27927?w=800",
                       tags: ["Nature", "Adventure", "Northern Lights"],
                       description: "Gateway to glaciers, geysers, and the mesmerizing Northern Lights.",
                       suggestedDates: "Nov 1 - Nov 8", category: .trending),
            Destination(id: UUID(), name: "New York", country: "USA",
                       imageURL: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800",
                       tags: ["Culture", "Food", "Shopping"],
                       description: "The city that never sleeps — Broadway, Central Park, and iconic skyline.",
                       suggestedDates: "Dec 15 - Dec 22", category: .popular),
            Destination(id: UUID(), name: "São Paulo", country: "Brazil",
                       imageURL: "https://images.unsplash.com/photo-1554168848-228452c09d00?w=800",
                       tags: ["Food", "Nightlife", "Culture"],
                       description: "South America's largest city with vibrant art, food, and music scenes.",
                       suggestedDates: "Feb 10 - Feb 18", category: .inspiration),
            Destination(id: UUID(), name: "Marrakech", country: "Morocco",
                       imageURL: "https://images.unsplash.com/photo-1597212618440-806262de4f6b?w=800",
                       tags: ["Culture", "Markets", "Architecture"],
                       description: "Exotic souks, stunning palaces, and the magic of the Sahara nearby.",
                       suggestedDates: "Oct 5 - Oct 12", category: .recommended),
            Destination(id: UUID(), name: "London", country: "United Kingdom",
                       imageURL: "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800",
                       tags: ["History", "Theater", "Culture"],
                       description: "Royal palaces, world-class museums, and legendary theater district.",
                       suggestedDates: "Jul 1 - Jul 8", category: .popular),
            Destination(id: UUID(), name: "Cancun", country: "Mexico",
                       imageURL: "https://images.unsplash.com/photo-1552074284-5e88ef1aef18?w=800",
                       tags: ["Beach", "Resorts", "Ruins"],
                       description: "Turquoise Caribbean waters, all-inclusive resorts, and Mayan ruins.",
                       suggestedDates: "Jan 10 - Jan 17", category: .trending)
        ]
    }

    // MARK: - Seed Trips & Bookings (4 trips, 8 bookings)

    private func seedTripsAndBookings() {
        let tripRome = UUID()
        let tripTokyo = UUID()
        let tripMexico = UUID()
        let tripParis = UUID()

        trips = [
            Trip(id: tripRome, name: "Girl's trip to Rome", destination: "Rome",
                 destinationCountry: "Italy",
                 imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800",
                 startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!,
                 endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 29))!,
                 travelers: ["Victoria", "Jaclyn", "Daphne", "Harper"],
                 status: .booked, itinerary: nil, bookings: []),
            Trip(id: tripTokyo, name: "Tokyo Adventure", destination: "Tokyo",
                 destinationCountry: "Japan",
                 imageURL: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800",
                 startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15))!,
                 endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 25))!,
                 travelers: ["Victoria", "Marcus"],
                 status: .planning, itinerary: nil, bookings: []),
            Trip(id: tripMexico, name: "Mexico City Weekend", destination: "Mexico City",
                 destinationCountry: "Mexico",
                 imageURL: "https://images.unsplash.com/photo-1518659526054-e4baac39d57d?w=800",
                 startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!,
                 endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 14))!,
                 travelers: ["Victoria", "Jaclyn", "Daphne"],
                 status: .completed, itinerary: nil, bookings: []),
            Trip(id: tripParis, name: "Paris in Spring", destination: "Paris",
                 destinationCountry: "France",
                 imageURL: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800",
                 startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 5))!,
                 endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 12))!,
                 travelers: ["Victoria"],
                 status: .planning, itinerary: nil, bookings: [])
        ]

        bookings = [
            // Rome trip bookings
            Booking(id: UUID(), type: .hotel, status: .confirmed,
                   confirmationNumber: "HT847291", tripId: tripRome,
                   details: "Portrait Roma - 5 night stay",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!,
                   price: 28255, checkInDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23)),
                   checkOutDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 28))),
            Booking(id: UUID(), type: .flight, status: .confirmed,
                   confirmationNumber: "FL293847", tripId: tripRome,
                   details: "United UA 412 - LAX to FCO",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23))!,
                   price: 2850, passengers: ["Victoria", "Jaclyn", "Daphne", "Harper"]),
            Booking(id: UUID(), type: .restaurant, status: .confirmed,
                   confirmationNumber: "RS182736", tripId: tripRome,
                   details: "Armando Al Pantheon - 4 guests",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 25))!,
                   guestCount: 4),
            Booking(id: UUID(), type: .carRental, status: .confirmed,
                   confirmationNumber: "CR459182", tripId: tripRome,
                   details: "Hertz Toyota Corolla - Rome Fiumicino",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24))!,
                   price: 270),
            // Mexico City completed bookings
            Booking(id: UUID(), type: .flight, status: .completed,
                   confirmationNumber: "FL738291", tripId: tripMexico,
                   details: "American AA 1290 - LAX to MEX",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!,
                   price: 680, passengers: ["Victoria", "Jaclyn", "Daphne"]),
            Booking(id: UUID(), type: .hotel, status: .completed,
                   confirmationNumber: "HT628194", tripId: tripMexico,
                   details: "Four Seasons Mexico City - 4 nights",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10))!,
                   price: 12800, checkInDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 10)),
                   checkOutDate: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 14))),
            // Tokyo trip bookings
            Booking(id: UUID(), type: .flight, status: .confirmed,
                   confirmationNumber: "FL982736", tripId: tripTokyo,
                   details: "ANA NH 105 - LAX to NRT",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15))!,
                   price: 3200, passengers: ["Victoria", "Marcus"]),
            Booking(id: UUID(), type: .hotel, status: .pending,
                   confirmationNumber: "HT019283", tripId: tripTokyo,
                   details: "Park Hyatt Tokyo - 10 nights",
                   date: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15))!,
                   price: 48000, checkInDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15)),
                   checkOutDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 25)))
        ]
    }

    // MARK: - Seed Hotels (22)

    private func seedHotels() {
        hotels = [
            // Rome (5)
            Hotel(id: UUID(), name: "Portrait Roma", brand: "Lungarno Collection",
                  starRating: 5, userRating: 5.0, ratingCount: 892,
                  location: "Rome, Italy", locationDetail: "Central location",
                  pricePerNight: 5651, totalPrice: 28255,
                  pointsCost: 1_255_768, originalPointsCost: 1_883_652,
                  amenities: ["Daily breakfast for 2", "Early check-in", "Late check-out", "$100 property credit", "Room upgrade", "Spa access"],
                  imageURLs: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
                             "https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800"],
                  tier: .theEdit,
                  description: "An intimate luxury hotel overlooking the Via Condotti, offering personalized service and stunning views of Rome's historic center."),
            Hotel(id: UUID(), name: "Hotel de Russie", brand: "Rocco Forte Hotels",
                  starRating: 5, userRating: 4.8, ratingCount: 1245,
                  location: "Rome, Italy", locationDetail: "Near Piazza del Popolo",
                  pricePerNight: 4200, totalPrice: 21000,
                  pointsCost: 980_000, originalPointsCost: 1_470_000,
                  amenities: ["Spa", "Garden", "Restaurant", "Bar", "Fitness center"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: .luxury,
                  description: "A stunning property set between Piazza del Popolo and the Spanish Steps with beautiful secret gardens."),
            Hotel(id: UUID(), name: "The St. Regis Rome", brand: "Marriott",
                  starRating: 5, userRating: 4.7, ratingCount: 987,
                  location: "Rome, Italy", locationDetail: "Near Trevi Fountain",
                  pricePerNight: 3800, totalPrice: 19000,
                  pointsCost: 850_000, originalPointsCost: 1_275_000,
                  amenities: ["Butler service", "Spa", "Restaurant", "Rooftop bar"],
                  imageURLs: ["https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800"],
                  tier: .premium,
                  description: "Grand dame hotel with opulent decor, impeccable butler service, and a prime location near the Trevi Fountain."),
            Hotel(id: UUID(), name: "Hotel Artemide", brand: "Independent",
                  starRating: 4, userRating: 4.6, ratingCount: 2341,
                  location: "Rome, Italy", locationDetail: "Via Nazionale",
                  pricePerNight: 220, totalPrice: 1100,
                  pointsCost: 95_000, originalPointsCost: 142_500,
                  amenities: ["Rooftop terrace", "Spa", "Restaurant", "Free WiFi"],
                  imageURLs: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"],
                  tier: nil,
                  description: "A charming Art Nouveau hotel on Via Nazionale with a rooftop restaurant and wellness center."),
            Hotel(id: UUID(), name: "Rome Cavalieri", brand: "Waldorf Astoria",
                  starRating: 5, userRating: 4.8, ratingCount: 1567,
                  location: "Rome, Italy", locationDetail: "Monte Mario",
                  pricePerNight: 4500, totalPrice: 22500,
                  pointsCost: 1_050_000, originalPointsCost: 1_575_000,
                  amenities: ["3 pools", "Spa", "Art collection", "La Pergola restaurant", "Shuttle to center"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: .luxury,
                  description: "Hilltop resort with a world-class art collection, three pools, and Rome's only 3-Michelin-star restaurant."),
            // Tokyo (4)
            Hotel(id: UUID(), name: "Park Hyatt Tokyo", brand: "Hyatt",
                  starRating: 5, userRating: 4.9, ratingCount: 1523,
                  location: "Tokyo, Japan", locationDetail: "Shinjuku",
                  pricePerNight: 4800, totalPrice: 48000,
                  pointsCost: 1_100_000, originalPointsCost: 1_650_000,
                  amenities: ["Spa", "Pool", "Restaurant", "Bar", "Fitness center", "City views"],
                  imageURLs: ["https://images.unsplash.com/photo-1590490360182-c33d955e2d60?w=800"],
                  tier: .luxury,
                  description: "A serene luxury retreat in Shinjuku with panoramic views of Mount Fuji and the city skyline."),
            Hotel(id: UUID(), name: "Hotel Nami Tokyo", brand: "Independent",
                  starRating: 4, userRating: 4.5, ratingCount: 645,
                  location: "Tokyo, Japan", locationDetail: "Shibuya",
                  pricePerNight: 280, totalPrice: 2800,
                  pointsCost: 120_000, originalPointsCost: 180_000,
                  amenities: ["Free WiFi", "Restaurant", "Onsen bath", "Concierge"],
                  imageURLs: ["https://images.unsplash.com/photo-1590490360182-c33d955e2d60?w=800"],
                  tier: nil,
                  description: "A stylish boutique hotel in the heart of Shibuya, blending modern design with traditional Japanese hospitality."),
            Hotel(id: UUID(), name: "Aman Tokyo", brand: "Aman",
                  starRating: 5, userRating: 4.9, ratingCount: 876,
                  location: "Tokyo, Japan", locationDetail: "Otemachi",
                  pricePerNight: 8500, totalPrice: 85000,
                  pointsCost: 2_100_000, originalPointsCost: 3_150_000,
                  amenities: ["Spa", "Pool", "Japanese garden", "Fine dining", "Tea room"],
                  imageURLs: ["https://images.unsplash.com/photo-1590490360182-c33d955e2d60?w=800"],
                  tier: .theEdit,
                  description: "Ultra-luxury urban sanctuary combining traditional Japanese aesthetics with modern minimalism."),
            Hotel(id: UUID(), name: "Dormy Inn Akihabara", brand: "Dormy Inn",
                  starRating: 3, userRating: 4.3, ratingCount: 3120,
                  location: "Tokyo, Japan", locationDetail: "Akihabara",
                  pricePerNight: 120, totalPrice: 1200,
                  pointsCost: 52_000, originalPointsCost: 78_000,
                  amenities: ["Onsen bath", "Free ramen", "Laundry", "Free WiFi"],
                  imageURLs: ["https://images.unsplash.com/photo-1590490360182-c33d955e2d60?w=800"],
                  tier: nil,
                  description: "Budget-friendly hotel famous for its complimentary late-night ramen and rooftop onsen."),
            // Paris (4)
            Hotel(id: UUID(), name: "Le Bristol Paris", brand: "Oetker Collection",
                  starRating: 5, userRating: 4.8, ratingCount: 2100,
                  location: "Paris, France", locationDetail: "Rue du Faubourg Saint-Honoré",
                  pricePerNight: 5200, totalPrice: 36400,
                  pointsCost: 1_200_000, originalPointsCost: 1_800_000,
                  amenities: ["Rooftop pool", "Spa", "3-star restaurant", "Garden", "Butler service"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: .theEdit,
                  description: "Palace hotel on Paris's most prestigious street, with a rooftop pool and Michelin-starred dining."),
            Hotel(id: UUID(), name: "Hôtel Plaza Athénée", brand: "Dorchester Collection",
                  starRating: 5, userRating: 4.7, ratingCount: 1890,
                  location: "Paris, France", locationDetail: "Avenue Montaigne",
                  pricePerNight: 4800, totalPrice: 33600,
                  pointsCost: 1_100_000, originalPointsCost: 1_650_000,
                  amenities: ["Alain Ducasse restaurant", "Spa", "Courtyard", "Eiffel view rooms"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: .luxury,
                  description: "Iconic Parisian palace with Avenue Montaigne address and Eiffel Tower views."),
            Hotel(id: UUID(), name: "Hôtel Monge", brand: "Independent",
                  starRating: 4, userRating: 4.5, ratingCount: 912,
                  location: "Paris, France", locationDetail: "Latin Quarter",
                  pricePerNight: 350, totalPrice: 2450,
                  pointsCost: 155_000, originalPointsCost: 232_500,
                  amenities: ["Free breakfast", "Concierge", "Spa bath", "Free WiFi"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: nil,
                  description: "Charming boutique hotel in the Latin Quarter with Panthéon views and Parisian charm."),
            Hotel(id: UUID(), name: "The Ritz Paris", brand: "Ritz",
                  starRating: 5, userRating: 4.9, ratingCount: 2540,
                  location: "Paris, France", locationDetail: "Place Vendôme",
                  pricePerNight: 7200, totalPrice: 50400,
                  pointsCost: 1_800_000, originalPointsCost: 2_700_000,
                  amenities: ["Ritz Club spa", "L'Espadon restaurant", "Ritz Bar", "Coco Chanel Suite", "Swimming pool"],
                  imageURLs: ["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800"],
                  tier: .theEdit,
                  description: "The legendary Ritz on Place Vendôme — where Coco Chanel lived and Hemingway drank."),
            // London (3)
            Hotel(id: UUID(), name: "The Savoy", brand: "Fairmont",
                  starRating: 5, userRating: 4.7, ratingCount: 3200,
                  location: "London, United Kingdom", locationDetail: "The Strand",
                  pricePerNight: 4100, totalPrice: 28700,
                  pointsCost: 950_000, originalPointsCost: 1_425_000,
                  amenities: ["Thames view", "Spa", "Savoy Grill", "American Bar", "Butler service"],
                  imageURLs: ["https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800"],
                  tier: .luxury,
                  description: "London's most iconic hotel on the Thames with legendary service since 1889."),
            Hotel(id: UUID(), name: "Premier Inn London Southwark", brand: "Premier Inn",
                  starRating: 3, userRating: 4.1, ratingCount: 5430,
                  location: "London, United Kingdom", locationDetail: "Bankside",
                  pricePerNight: 145, totalPrice: 1015,
                  pointsCost: 62_000, originalPointsCost: 93_000,
                  amenities: ["Free WiFi", "Restaurant", "Bar", "Air conditioning"],
                  imageURLs: ["https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800"],
                  tier: nil,
                  description: "Affordable and reliable stay near the Tate Modern and Borough Market."),
            Hotel(id: UUID(), name: "Claridge's", brand: "Maybourne",
                  starRating: 5, userRating: 4.8, ratingCount: 1980,
                  location: "London, United Kingdom", locationDetail: "Mayfair",
                  pricePerNight: 5800, totalPrice: 40600,
                  pointsCost: 1_350_000, originalPointsCost: 2_025_000,
                  amenities: ["Art Deco design", "Spa", "Gordon Ramsay restaurant", "Fumoir bar"],
                  imageURLs: ["https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800"],
                  tier: .theEdit,
                  description: "The quintessential Art Deco palace in Mayfair — London's grandest address."),
            // Barcelona (2)
            Hotel(id: UUID(), name: "W Barcelona", brand: "W Hotels",
                  starRating: 5, userRating: 4.5, ratingCount: 2890,
                  location: "Barcelona, Spain", locationDetail: "Barceloneta Beach",
                  pricePerNight: 3200, totalPrice: 22400,
                  pointsCost: 740_000, originalPointsCost: 1_110_000,
                  amenities: ["Beachfront", "Infinity pool", "Spa", "WET deck", "SALT restaurant"],
                  imageURLs: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"],
                  tier: .premium,
                  description: "Sail-shaped landmark on Barceloneta beach with stunning Mediterranean views."),
            Hotel(id: UUID(), name: "Hotel Casa Fuster", brand: "Monument Hotels",
                  starRating: 5, userRating: 4.6, ratingCount: 1450,
                  location: "Barcelona, Spain", locationDetail: "Passeig de Gràcia",
                  pricePerNight: 380, totalPrice: 2660,
                  pointsCost: 165_000, originalPointsCost: 247_500,
                  amenities: ["Rooftop pool", "Café Vienés jazz bar", "Spa", "Restaurant"],
                  imageURLs: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"],
                  tier: nil,
                  description: "Modernist masterpiece by Domènech i Montaner on Passeig de Gràcia."),
            // Cancun (1)
            Hotel(id: UUID(), name: "Ritz-Carlton Cancun", brand: "Ritz-Carlton",
                  starRating: 5, userRating: 4.7, ratingCount: 1890,
                  location: "Cancun, Mexico", locationDetail: "Hotel Zone",
                  pricePerNight: 2800, totalPrice: 19600,
                  pointsCost: 650_000, originalPointsCost: 975_000,
                  amenities: ["Beach", "5 pools", "Spa", "5 restaurants", "Water sports"],
                  imageURLs: ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"],
                  tier: .luxury,
                  description: "Beachfront luxury resort in the Hotel Zone with Caribbean views and Mayan-inspired spa."),
            // Bali (1)
            Hotel(id: UUID(), name: "Four Seasons Resort Bali at Sayan", brand: "Four Seasons",
                  starRating: 5, userRating: 4.9, ratingCount: 1120,
                  location: "Bali, Indonesia", locationDetail: "Ubud",
                  pricePerNight: 6800, totalPrice: 47600,
                  pointsCost: 1_600_000, originalPointsCost: 2_400_000,
                  amenities: ["Rice terrace views", "Infinity pool", "Spa", "Cooking classes", "Yoga pavilion"],
                  imageURLs: ["https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800"],
                  tier: .theEdit,
                  description: "A riverside sanctuary nestled among Ubud's rice terraces with world-class wellness."),
            // Reykjavik (1)
            Hotel(id: UUID(), name: "The Retreat at Blue Lagoon", brand: "Blue Lagoon",
                  starRating: 5, userRating: 4.8, ratingCount: 780,
                  location: "Reykjavik, Iceland", locationDetail: "Blue Lagoon",
                  pricePerNight: 4200, totalPrice: 29400,
                  pointsCost: 980_000, originalPointsCost: 1_470_000,
                  amenities: ["Private lagoon", "Spa", "Lava restaurant", "In-water bar", "Geothermal suite"],
                  imageURLs: ["https://images.unsplash.com/photo-1504829857797-ddff29c27927?w=800"],
                  tier: .theEdit,
                  description: "Subterranean luxury suites built into a lava landscape with private Blue Lagoon access."),
            // New York (1)
            Hotel(id: UUID(), name: "The Plaza", brand: "Fairmont",
                  starRating: 5, userRating: 4.6, ratingCount: 4560,
                  location: "New York, USA", locationDetail: "Central Park South",
                  pricePerNight: 5500, totalPrice: 38500,
                  pointsCost: 1_280_000, originalPointsCost: 1_920_000,
                  amenities: ["Central Park views", "Palm Court", "Spa", "Butler service", "Shopping arcade"],
                  imageURLs: ["https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800"],
                  tier: .luxury,
                  description: "New York's most legendary hotel overlooking Central Park since 1907.")
        ]
    }

    // MARK: - Seed Flights (24)

    private func seedFlights() {
        flights = [
            // LAX → Rome (FCO)
            Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 412",
                   departureAirport: "LAX", arrivalAirport: "FCO",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 17, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 13, minute: 45))!,
                   price: 2850, pointsCost: 85000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 178",
                   departureAirport: "LAX", arrivalAirport: "FCO",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 21, minute: 15))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 17, minute: 30))!,
                   price: 2450, pointsCost: 72000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "ITA Airways", flightNumber: "AZ 621",
                   departureAirport: "LAX", arrivalAirport: "FCO",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 14, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 10, minute: 30))!,
                   price: 980, pointsCost: 42000, cabinClass: .economy, status: .scheduled),
            Flight(id: UUID(), airline: "Emirates", flightNumber: "EK 216",
                   departureAirport: "LAX", arrivalAirport: "FCO",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 23, hour: 16, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 24, hour: 18, minute: 30))!,
                   price: 8500, pointsCost: 180000, cabinClass: .first, status: .scheduled),
            // LAX → Tokyo (NRT)
            Flight(id: UUID(), airline: "ANA", flightNumber: "NH 105",
                   departureAirport: "LAX", arrivalAirport: "NRT",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15, hour: 11, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 16, hour: 15, minute: 30))!,
                   price: 3200, pointsCost: 95000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "Japan Airlines", flightNumber: "JL 15",
                   departureAirport: "LAX", arrivalAirport: "NRT",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15, hour: 13, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 16, hour: 17, minute: 0))!,
                   price: 1100, pointsCost: 48000, cabinClass: .economy, status: .scheduled),
            Flight(id: UUID(), airline: "Singapore Airlines", flightNumber: "SQ 11",
                   departureAirport: "LAX", arrivalAirport: "NRT",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15, hour: 0, minute: 5))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 16, hour: 6, minute: 30))!,
                   price: 5800, pointsCost: 140000, cabinClass: .first, status: .scheduled),
            Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 32",
                   departureAirport: "LAX", arrivalAirport: "NRT",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 15, hour: 10, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 16, hour: 14, minute: 45))!,
                   price: 850, pointsCost: 38000, cabinClass: .economy, status: .scheduled),
            // LAX → Paris (CDG)
            Flight(id: UUID(), airline: "Air France", flightNumber: "AF 65",
                   departureAirport: "LAX", arrivalAirport: "CDG",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 5, hour: 16, minute: 45))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 6, hour: 12, minute: 15))!,
                   price: 2650, pointsCost: 78000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 264",
                   departureAirport: "LAX", arrivalAirport: "CDG",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 5, hour: 20, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 6, hour: 15, minute: 45))!,
                   price: 780, pointsCost: 35000, cabinClass: .economy, status: .scheduled),
            Flight(id: UUID(), airline: "Lufthansa", flightNumber: "LH 453",
                   departureAirport: "LAX", arrivalAirport: "CDG",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 5, hour: 15, minute: 20))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2026, month: 4, day: 6, hour: 13, minute: 0))!,
                   price: 3100, pointsCost: 88000, cabinClass: .business, status: .scheduled),
            // JFK → London (LHR)
            Flight(id: UUID(), airline: "British Airways", flightNumber: "BA 178",
                   departureAirport: "JFK", arrivalAirport: "LHR",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1, hour: 19, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2, hour: 7, minute: 15))!,
                   price: 4200, pointsCost: 110000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 100",
                   departureAirport: "JFK", arrivalAirport: "LHR",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 1, hour: 22, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 2, hour: 10, minute: 45))!,
                   price: 680, pointsCost: 32000, cabinClass: .economy, status: .scheduled),
            // SFO → Barcelona (BCN)
            Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 94",
                   departureAirport: "SFO", arrivalAirport: "BCN",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10, hour: 17, minute: 15))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 11, hour: 13, minute: 0))!,
                   price: 2200, pointsCost: 65000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "Iberia", flightNumber: "IB 2624",
                   departureAirport: "SFO", arrivalAirport: "BCN",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 10, hour: 21, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 11, hour: 17, minute: 45))!,
                   price: 620, pointsCost: 28000, cabinClass: .economy, status: .scheduled),
            // ORD → Cancun (CUN)
            Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 1844",
                   departureAirport: "ORD", arrivalAirport: "CUN",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 10, hour: 8, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 10, hour: 13, minute: 15))!,
                   price: 450, pointsCost: 18000, cabinClass: .economy, status: .scheduled),
            Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 1567",
                   departureAirport: "ORD", arrivalAirport: "CUN",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 10, hour: 11, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 10, hour: 15, minute: 30))!,
                   price: 1800, pointsCost: 52000, cabinClass: .business, status: .scheduled),
            // MIA → São Paulo (GRU)
            Flight(id: UUID(), airline: "LATAM", flightNumber: "LA 8180",
                   departureAirport: "MIA", arrivalAirport: "GRU",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10, hour: 21, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 11, hour: 8, minute: 30))!,
                   price: 2800, pointsCost: 82000, cabinClass: .business, status: .scheduled),
            Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 953",
                   departureAirport: "MIA", arrivalAirport: "GRU",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 10, hour: 19, minute: 45))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 11, hour: 7, minute: 0))!,
                   price: 750, pointsCost: 35000, cabinClass: .economy, status: .scheduled),
            // SEA → Reykjavik (KEF)
            Flight(id: UUID(), airline: "Icelandair", flightNumber: "FI 680",
                   departureAirport: "SEA", arrivalAirport: "KEF",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1, hour: 16, minute: 30))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 6, minute: 0))!,
                   price: 580, pointsCost: 25000, cabinClass: .economy, status: .scheduled),
            Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 208",
                   departureAirport: "SEA", arrivalAirport: "KEF",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1, hour: 20, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 2, hour: 9, minute: 15))!,
                   price: 2400, pointsCost: 70000, cabinClass: .business, status: .scheduled),
            // JFK → New York to Bali (DPS) via Singapore
            Flight(id: UUID(), airline: "Singapore Airlines", flightNumber: "SQ 25",
                   departureAirport: "JFK", arrivalAirport: "DPS",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1, hour: 23, minute: 45))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 3, hour: 11, minute: 30))!,
                   price: 4500, pointsCost: 120000, cabinClass: .business, status: .scheduled),
            // LAX → Marrakech (RAK) via Paris
            Flight(id: UUID(), airline: "Air France", flightNumber: "AF 69",
                   departureAirport: "LAX", arrivalAirport: "RAK",
                   departureTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 5, hour: 16, minute: 0))!,
                   arrivalTime: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 6, hour: 15, minute: 45))!,
                   price: 1200, pointsCost: 52000, cabinClass: .economy, status: .scheduled)
        ]
    }

    // MARK: - Seed Restaurants (18)

    private func seedRestaurants() {
        restaurants = [
            // Rome (5)
            Restaurant(id: UUID(), name: "Armando Al Pantheon", cuisine: "Traditional Roman",
                      rating: 4.7, priceLevel: "$$$",
                      imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                      location: "Near the Pantheon, Rome",
                      reservationDate: Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 25))!,
                      reservationTime: "8:00 PM", guestCount: 4, isBooked: true,
                      description: "A beloved trattoria steps from the Pantheon, serving authentic Roman cuisine since 1961."),
            Restaurant(id: UUID(), name: "La Pergola", cuisine: "Fine Dining Italian",
                      rating: 4.9, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1559339352-11d035aa65de?w=800",
                      location: "Rome Cavalieri Hotel",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Rome's only three-Michelin-star restaurant with panoramic city views."),
            Restaurant(id: UUID(), name: "Roscioli", cuisine: "Roman Deli & Wine Bar",
                      rating: 4.6, priceLevel: "$$",
                      imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                      location: "Via dei Giubbonari, Rome",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "A beloved Roman institution combining a bakery, deli, and wine bar with outstanding cured meats and cheeses."),
            Restaurant(id: UUID(), name: "Da Enzo al 29", cuisine: "Roman Trattoria",
                      rating: 4.5, priceLevel: "$$",
                      imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                      location: "Trastevere, Rome",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Trastevere gem famous for cacio e pepe and carbonara. No reservations — arrive early."),
            Restaurant(id: UUID(), name: "Pierluigi", cuisine: "Seafood Italian",
                      rating: 4.4, priceLevel: "$$$",
                      imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                      location: "Piazza de' Ricci, Rome",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Elegant outdoor dining in a charming piazza, known for the freshest seafood in Rome."),
            // Tokyo (4)
            Restaurant(id: UUID(), name: "Sukiyabashi Jiro", cuisine: "Japanese Sushi",
                      rating: 4.9, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800",
                      location: "Ginza, Tokyo",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "The legendary sushi restaurant made famous worldwide, offering an intimate omakase experience."),
            Restaurant(id: UUID(), name: "Narisawa", cuisine: "Innovative Japanese",
                      rating: 4.8, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800",
                      location: "Minami-Aoyama, Tokyo",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Two-Michelin-star restaurant blending French techniques with Japanese forest-to-table philosophy."),
            Restaurant(id: UUID(), name: "Ichiran Shibuya", cuisine: "Ramen",
                      rating: 4.3, priceLevel: "$",
                      imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800",
                      location: "Shibuya, Tokyo",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Iconic solo-dining ramen chain with individual booths and customizable tonkotsu broth."),
            Restaurant(id: UUID(), name: "Gonpachi Nishi-Azabu", cuisine: "Japanese Izakaya",
                      rating: 4.4, priceLevel: "$$",
                      imageURL: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=800",
                      location: "Nishi-Azabu, Tokyo",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "The 'Kill Bill' restaurant — dramatic wooden interiors with soba, yakitori, and tempura."),
            // Paris (3)
            Restaurant(id: UUID(), name: "Le Cinq", cuisine: "French Fine Dining",
                      rating: 4.8, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
                      location: "Four Seasons George V, Paris",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Two Michelin-starred restaurant in the iconic Four Seasons Hotel George V."),
            Restaurant(id: UUID(), name: "Le Comptoir du Panthéon", cuisine: "French Bistro",
                      rating: 4.3, priceLevel: "$$",
                      imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
                      location: "Latin Quarter, Paris",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Classic Parisian bistro across from the Panthéon with steak frites and crème brûlée."),
            Restaurant(id: UUID(), name: "L'Ambroisie", cuisine: "French Haute Cuisine",
                      rating: 4.9, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
                      location: "Place des Vosges, Paris",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Three-Michelin-star temple of French gastronomy on the historic Place des Vosges."),
            // Cancun (2)
            Restaurant(id: UUID(), name: "Puerto Madero", cuisine: "Mexican Seafood",
                      rating: 4.5, priceLevel: "$$$",
                      imageURL: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800",
                      location: "Hotel Zone, Cancun",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Lagoon-side fine dining with fresh lobster, ceviche, and panoramic sunset views."),
            Restaurant(id: UUID(), name: "Tacos Rigo", cuisine: "Mexican Street Food",
                      rating: 4.2, priceLevel: "$",
                      imageURL: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800",
                      location: "Hotel Zone, Cancun",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Beloved street taco stand with pastor, carnitas, and fresh salsas until 4 AM."),
            // London (2)
            Restaurant(id: UUID(), name: "Dishoom King's Cross", cuisine: "Indian",
                      rating: 4.6, priceLevel: "$$",
                      imageURL: "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800",
                      location: "King's Cross, London",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Bombay-inspired café famous for its bacon naan roll breakfast and black daal."),
            Restaurant(id: UUID(), name: "Restaurant Gordon Ramsay", cuisine: "French Fine Dining",
                      rating: 4.8, priceLevel: "$$$$",
                      imageURL: "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
                      location: "Chelsea, London",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Gordon Ramsay's flagship three-Michelin-star restaurant with classic French cuisine."),
            // Barcelona (1)
            Restaurant(id: UUID(), name: "Tickets", cuisine: "Spanish Tapas",
                      rating: 4.7, priceLevel: "$$$",
                      imageURL: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800",
                      location: "Paral·lel, Barcelona",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Albert Adrià's playful tapas bar with circus-themed decor and molecular gastronomy."),
            // Bali (1)
            Restaurant(id: UUID(), name: "Locavore", cuisine: "Indonesian Fine Dining",
                      rating: 4.7, priceLevel: "$$$",
                      imageURL: "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=800",
                      location: "Ubud, Bali",
                      reservationDate: nil, reservationTime: nil, guestCount: nil, isBooked: false,
                      description: "Asia's top farm-to-table restaurant using only Indonesian ingredients in creative tasting menus.")
        ]
    }

    // MARK: - Seed Car Rentals (16)

    private func seedCarRentals() {
        carRentals = [
            // Rome (5)
            CarRental(id: UUID(), company: "Hertz", carType: .economy,
                     model: "Toyota Corolla", pricePerDay: 45, totalPrice: 270,
                     pointsCost: 12_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Automatic", "GPS", "Bluetooth", "A/C"],
                     seating: 5),
            CarRental(id: UUID(), company: "Enterprise", carType: .midsize,
                     model: "Honda Accord", pricePerDay: 65, totalPrice: 390,
                     pointsCost: 18_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "Leather seats"],
                     seating: 5),
            CarRental(id: UUID(), company: "Avis", carType: .suv,
                     model: "BMW X5", pricePerDay: 120, totalPrice: 720,
                     pointsCost: 35_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "Panoramic roof", "Heated seats"],
                     seating: 5),
            CarRental(id: UUID(), company: "Hertz", carType: .luxury,
                     model: "Mercedes E-Class", pricePerDay: 180, totalPrice: 1080,
                     pointsCost: 52_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "Leather seats", "Premium audio", "Heated seats"],
                     seating: 5),
            CarRental(id: UUID(), company: "Europcar", carType: .compact,
                     model: "Fiat 500", pricePerDay: 35, totalPrice: 210,
                     pointsCost: 9_000, pickupLocation: "Rome Fiumicino Airport",
                     dropoffLocation: "Rome Fiumicino Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Manual", "GPS", "A/C", "Bluetooth"],
                     seating: 4),
            // Tokyo (3)
            CarRental(id: UUID(), company: "Nippon Rent-A-Car", carType: .compact,
                     model: "Toyota Yaris", pricePerDay: 40, totalPrice: 400,
                     pointsCost: 10_000, pickupLocation: "Tokyo Narita Airport",
                     dropoffLocation: "Tokyo Narita Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Automatic", "GPS", "Bluetooth", "A/C"],
                     seating: 5),
            CarRental(id: UUID(), company: "Times Car Rental", carType: .economy,
                     model: "Honda Fit", pricePerDay: 35, totalPrice: 350,
                     pointsCost: 9_500, pickupLocation: "Tokyo Haneda Airport",
                     dropoffLocation: "Tokyo Haneda Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Automatic", "GPS", "ETC card", "A/C"],
                     seating: 5),
            CarRental(id: UUID(), company: "Nippon Rent-A-Car", carType: .luxury,
                     model: "Lexus ES", pricePerDay: 200, totalPrice: 2000,
                     pointsCost: 58_000, pickupLocation: "Tokyo Narita Airport",
                     dropoffLocation: "Tokyo Narita Airport",
                     imageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800",
                     features: ["Automatic", "GPS", "Premium audio", "Heated seats", "Safety suite"],
                     seating: 5),
            // Paris (3)
            CarRental(id: UUID(), company: "Sixt", carType: .midsize,
                     model: "Peugeot 308", pricePerDay: 55, totalPrice: 385,
                     pointsCost: 15_000, pickupLocation: "Paris Charles de Gaulle Airport",
                     dropoffLocation: "Paris Charles de Gaulle Airport",
                     imageURL: "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "A/C"],
                     seating: 5),
            CarRental(id: UUID(), company: "Europcar", carType: .luxury,
                     model: "BMW 5 Series", pricePerDay: 195, totalPrice: 1365,
                     pointsCost: 55_000, pickupLocation: "Paris Charles de Gaulle Airport",
                     dropoffLocation: "Paris Charles de Gaulle Airport",
                     imageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "Leather seats", "Heated seats"],
                     seating: 5),
            CarRental(id: UUID(), company: "Hertz", carType: .compact,
                     model: "Renault Clio", pricePerDay: 38, totalPrice: 266,
                     pointsCost: 10_500, pickupLocation: "Paris Orly Airport",
                     dropoffLocation: "Paris Orly Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Manual", "GPS", "A/C", "Bluetooth"],
                     seating: 5),
            // Cancun (2)
            CarRental(id: UUID(), company: "Hertz", carType: .suv,
                     model: "Jeep Wrangler", pricePerDay: 95, totalPrice: 665,
                     pointsCost: 28_000, pickupLocation: "Cancun International Airport",
                     dropoffLocation: "Cancun International Airport",
                     imageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800",
                     features: ["Automatic", "GPS", "4WD", "Convertible top", "A/C"],
                     seating: 5),
            CarRental(id: UUID(), company: "Enterprise", carType: .economy,
                     model: "Nissan Versa", pricePerDay: 38, totalPrice: 266,
                     pointsCost: 10_000, pickupLocation: "Cancun International Airport",
                     dropoffLocation: "Cancun International Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Automatic", "GPS", "A/C", "Bluetooth"],
                     seating: 5),
            // London (2)
            CarRental(id: UUID(), company: "Sixt", carType: .luxury,
                     model: "Range Rover Sport", pricePerDay: 350, totalPrice: 2450,
                     pointsCost: 95_000, pickupLocation: "London Heathrow Airport",
                     dropoffLocation: "London Heathrow Airport",
                     imageURL: "https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "Leather seats", "Heated seats", "Panoramic roof"],
                     seating: 5),
            CarRental(id: UUID(), company: "Avis", carType: .compact,
                     model: "VW Golf", pricePerDay: 48, totalPrice: 336,
                     pointsCost: 13_000, pickupLocation: "London Heathrow Airport",
                     dropoffLocation: "London Heathrow Airport",
                     imageURL: "https://images.unsplash.com/photo-1549317661-bd32c8ce0afa?w=800",
                     features: ["Automatic", "GPS", "Apple CarPlay", "A/C"],
                     seating: 5),
            // Bali (1)
            CarRental(id: UUID(), company: "Bali Car Rental", carType: .suv,
                     model: "Toyota Fortuner", pricePerDay: 55, totalPrice: 385,
                     pointsCost: 15_000, pickupLocation: "Bali Ngurah Rai Airport",
                     dropoffLocation: "Bali Ngurah Rai Airport",
                     imageURL: "https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800",
                     features: ["Automatic", "GPS", "A/C", "Driver optional"],
                     seating: 7)
        ]
    }

    // MARK: - Seed Itinerary Themes

    private func seedItineraryThemes() {
        itineraryThemes = [
            ItineraryTheme(id: UUID(), title: "Take in Roman history",
                          subtitle: "Explore ancient ruins, Renaissance art, and centuries of culture",
                          tags: ["Historical sites", "5-star hotel", "Local food"],
                          imageURL: "https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800"),
            ItineraryTheme(id: UUID(), title: "Luxury shopping & dining",
                          subtitle: "Designer boutiques, Michelin restaurants, and VIP experiences",
                          tags: ["Shopping", "High-end dining", "Spa"],
                          imageURL: "https://images.unsplash.com/photo-1515542622106-78bda8ba0e5b?w=800"),
            ItineraryTheme(id: UUID(), title: "Local hidden gems",
                          subtitle: "Off-the-beaten-path trattorias, artisan workshops, and secret gardens",
                          tags: ["Local food", "Art", "Walking tours"],
                          imageURL: "https://images.unsplash.com/photo-1529260830199-42c24126f198?w=800")
        ]
    }

    // MARK: - Thread-safe mutations

    func addBooking(_ booking: Booking) {
        lock.lock()
        defer { lock.unlock() }
        bookings.append(booking)
        // Link to trip
        if let idx = trips.firstIndex(where: { $0.id == booking.tripId }) {
            trips[idx].bookings.append(booking.id)
        }
    }

    func updateBooking(id: UUID, update: (inout Booking) -> Void) -> Booking? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else { return nil }
        update(&bookings[idx])
        return bookings[idx]
    }

    func removeBooking(id: UUID) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else { return false }
        let booking = bookings.remove(at: idx)
        if let tripIdx = trips.firstIndex(where: { $0.id == booking.tripId }) {
            trips[tripIdx].bookings.removeAll { $0 == id }
        }
        return true
    }

    func addTrip(_ trip: Trip) {
        lock.lock()
        defer { lock.unlock() }
        trips.append(trip)
    }

    func updateTrip(id: UUID, update: (inout Trip) -> Void) -> Trip? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = trips.firstIndex(where: { $0.id == id }) else { return nil }
        update(&trips[idx])
        return trips[idx]
    }

    func updateHotel(id: UUID, update: (inout Hotel) -> Void) -> Hotel? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = hotels.firstIndex(where: { $0.id == id }) else { return nil }
        update(&hotels[idx])
        return hotels[idx]
    }

    func updateUser(_ update: (inout User) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        update(&user)
    }

    func updateRestaurant(id: UUID, update: (inout Restaurant) -> Void) -> Restaurant? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = restaurants.firstIndex(where: { $0.id == id }) else { return nil }
        update(&restaurants[idx])
        return restaurants[idx]
    }

    func updateCarRental(id: UUID, update: (inout CarRental) -> Void) -> CarRental? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = carRentals.firstIndex(where: { $0.id == id }) else { return nil }
        update(&carRentals[idx])
        return carRentals[idx]
    }

    func updateFlight(id: UUID, update: (inout Flight) -> Void) -> Flight? {
        lock.lock()
        defer { lock.unlock() }
        guard let idx = flights.firstIndex(where: { $0.id == id }) else { return nil }
        update(&flights[idx])
        return flights[idx]
    }

    func generateConfirmationNumber(prefix: String) -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let random = (0..<6).map { _ in chars.randomElement()! }
        return prefix + String(random)
    }
}
