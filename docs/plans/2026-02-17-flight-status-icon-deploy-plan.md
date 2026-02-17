# Flight Status, App Icon & Deploy — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Flighty-style live flight status card to the Home screen with simulated real-time status, create a gold-diamond app icon, and configure for personal phone deployment via Railway.

**Architecture:** Extend the Flight model with gate/terminal fields. Make both DataStores (iOS embedded + Vapor) compute flight times relative to "now" so the demo always feels live. Add a FlightStatusSimulator that deterministically assigns gate/status based on time offsets. Create a new FlightStatusCard SwiftUI component on the Home screen. Generate a 1024x1024 app icon via SVG/Playwright. Document personal phone deployment steps.

**Tech Stack:** SwiftUI, Vapor 4, Playwright (icon generation)

---

### Task 1: Extend Flight Model with Gate/Terminal Fields

**Files:**
- Modify: `DCETravel/DCETravel/Models/Flight.swift`
- Modify: `DCETravelAPI/Sources/App/Models/Flight.swift`

**Step 1: Add fields to iOS Flight model**

Add three optional fields after `status`:

```swift
struct Flight: Identifiable, Codable, Hashable {
    // ... existing fields ...
    var status: FlightStatus
    var gate: String?
    var terminal: String?
    var baggageClaim: String?
    // ... rest unchanged ...
}
```

Also add a new status case `checkIn` to FlightStatus:

```swift
enum FlightStatus: String, Codable {
    case scheduled = "Scheduled"
    case checkIn = "Check-in Open"
    case delayed = "Delayed"
    case boarding = "Boarding"
    case inFlight = "In Flight"
    case landed = "Landed"
    case cancelled = "Cancelled"
}
```

**Step 2: Add same fields to Vapor Flight model**

Mirror the exact same changes in `DCETravelAPI/Sources/App/Models/Flight.swift`.

**Step 3: Build both targets**

```bash
xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5
cd DCETravelAPI && swift build 2>&1 | tail -5
```

Expected: Both BUILD SUCCEEDED (new optional fields don't break existing code).

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/Models/Flight.swift DCETravelAPI/Sources/App/Models/Flight.swift
git commit -m "feat: add gate, terminal, baggageClaim fields to Flight model"
```

---

### Task 2: Make DataStore Flight Times Dynamic (iOS)

**Files:**
- Modify: `DCETravel/DCETravel/Services/Server/DataStore.swift`

**Step 1: Replace `seedFlights()` with dynamic time computation**

Replace the entire `seedFlights()` method. Instead of `DateComponents(year: 2025, month: 9, ...)`, use offsets from `Date()`:

```swift
private func seedFlights() {
    let now = Date()

    // Helper: create a date offset from now
    func date(hoursFromNow h: Double) -> Date {
        now.addingTimeInterval(h * 3600)
    }

    // Helper: deterministic gate/terminal from flight number
    func gateInfo(for flightNumber: String) -> (gate: String, terminal: String) {
        let hash = abs(flightNumber.hashValue)
        let gateNum = (hash % 60) + 1
        let termNum = (hash % 8) + 1
        let letter = ["A", "B", "C"][hash % 3]
        return ("\(gateNum)\(letter)", "Terminal \(termNum)")
    }

    flights = [
        // LAX → Rome (FCO) — Rome trip flights
        // UA 412: YOUR BOOKED FLIGHT — departs in ~6 hours (the Flighty card target)
        Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 412",
               departureAirport: "LAX", arrivalAirport: "FCO",
               departureTime: date(hoursFromNow: 6), arrivalTime: date(hoursFromNow: 18.25),
               price: 2850, pointsCost: 85000, cabinClass: .business, status: .scheduled,
               gate: gateInfo(for: "UA 412").gate, terminal: gateInfo(for: "UA 412").terminal),
        // DL 178: Departed 3h ago, currently in flight
        Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 178",
               departureAirport: "LAX", arrivalAirport: "FCO",
               departureTime: date(hoursFromNow: -3), arrivalTime: date(hoursFromNow: 9.5),
               price: 2450, pointsCost: 72000, cabinClass: .business, status: .inFlight,
               gate: gateInfo(for: "DL 178").gate, terminal: gateInfo(for: "DL 178").terminal),
        // AZ 621: Landed 1h ago
        Flight(id: UUID(), airline: "ITA Airways", flightNumber: "AZ 621",
               departureAirport: "LAX", arrivalAirport: "FCO",
               departureTime: date(hoursFromNow: -13.5), arrivalTime: date(hoursFromNow: -1),
               price: 980, pointsCost: 42000, cabinClass: .economy, status: .landed,
               gate: gateInfo(for: "AZ 621").gate, terminal: gateInfo(for: "AZ 621").terminal,
               baggageClaim: "Carousel 7"),
        // EK 216: Departs tomorrow
        Flight(id: UUID(), airline: "Emirates", flightNumber: "EK 216",
               departureAirport: "LAX", arrivalAirport: "FCO",
               departureTime: date(hoursFromNow: 26), arrivalTime: date(hoursFromNow: 38.5),
               price: 8500, pointsCost: 180000, cabinClass: .first, status: .scheduled),

        // LAX → Tokyo (NRT) — Tokyo trip flights
        Flight(id: UUID(), airline: "ANA", flightNumber: "NH 105",
               departureAirport: "LAX", arrivalAirport: "NRT",
               departureTime: date(hoursFromNow: 14), arrivalTime: date(hoursFromNow: 25.5),
               price: 3200, pointsCost: 95000, cabinClass: .business, status: .scheduled),
        Flight(id: UUID(), airline: "Japan Airlines", flightNumber: "JL 15",
               departureAirport: "LAX", arrivalAirport: "NRT",
               departureTime: date(hoursFromNow: 16.5), arrivalTime: date(hoursFromNow: 28),
               price: 1100, pointsCost: 48000, cabinClass: .economy, status: .scheduled),
        Flight(id: UUID(), airline: "Singapore Airlines", flightNumber: "SQ 11",
               departureAirport: "LAX", arrivalAirport: "NRT",
               departureTime: date(hoursFromNow: 3), arrivalTime: date(hoursFromNow: 14.4),
               price: 5800, pointsCost: 140000, cabinClass: .first, status: .scheduled,
               gate: gateInfo(for: "SQ 11").gate, terminal: gateInfo(for: "SQ 11").terminal),
        Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 32",
               departureAirport: "LAX", arrivalAirport: "NRT",
               departureTime: date(hoursFromNow: 13.5), arrivalTime: date(hoursFromNow: 24.75),
               price: 850, pointsCost: 38000, cabinClass: .economy, status: .scheduled),

        // LAX → Paris (CDG)
        Flight(id: UUID(), airline: "Air France", flightNumber: "AF 65",
               departureAirport: "LAX", arrivalAirport: "CDG",
               departureTime: date(hoursFromNow: 20), arrivalTime: date(hoursFromNow: 31.5),
               price: 2650, pointsCost: 78000, cabinClass: .business, status: .scheduled),
        Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 264",
               departureAirport: "LAX", arrivalAirport: "CDG",
               departureTime: date(hoursFromNow: 23), arrivalTime: date(hoursFromNow: 34.75),
               price: 780, pointsCost: 35000, cabinClass: .economy, status: .scheduled),
        Flight(id: UUID(), airline: "Lufthansa", flightNumber: "LH 453",
               departureAirport: "LAX", arrivalAirport: "CDG",
               departureTime: date(hoursFromNow: 18.3), arrivalTime: date(hoursFromNow: 30),
               price: 3100, pointsCost: 88000, cabinClass: .business, status: .scheduled),

        // JFK → London (LHR)
        Flight(id: UUID(), airline: "British Airways", flightNumber: "BA 178",
               departureAirport: "JFK", arrivalAirport: "LHR",
               departureTime: date(hoursFromNow: 10), arrivalTime: date(hoursFromNow: 17.5),
               price: 4200, pointsCost: 120000, cabinClass: .business, status: .scheduled),
        Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 100",
               departureAirport: "JFK", arrivalAirport: "LHR",
               departureTime: date(hoursFromNow: 8), arrivalTime: date(hoursFromNow: 15.7),
               price: 680, pointsCost: 32000, cabinClass: .economy, status: .scheduled),

        // SFO → Barcelona (BCN)
        Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 94",
               departureAirport: "SFO", arrivalAirport: "BCN",
               departureTime: date(hoursFromNow: 30), arrivalTime: date(hoursFromNow: 42),
               price: 2200, pointsCost: 65000, cabinClass: .business, status: .scheduled),
        Flight(id: UUID(), airline: "Iberia", flightNumber: "IB 2624",
               departureAirport: "SFO", arrivalAirport: "BCN",
               departureTime: date(hoursFromNow: 28), arrivalTime: date(hoursFromNow: 39),
               price: 620, pointsCost: 28000, cabinClass: .economy, status: .scheduled),

        // ORD → Cancun (CUN)
        Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 1844",
               departureAirport: "ORD", arrivalAirport: "CUN",
               departureTime: date(hoursFromNow: 22), arrivalTime: date(hoursFromNow: 26.5),
               price: 450, pointsCost: 18000, cabinClass: .economy, status: .scheduled),
        Flight(id: UUID(), airline: "United Airlines", flightNumber: "UA 1567",
               departureAirport: "ORD", arrivalAirport: "CUN",
               departureTime: date(hoursFromNow: 34), arrivalTime: date(hoursFromNow: 38.5),
               price: 1800, pointsCost: 55000, cabinClass: .business, status: .scheduled),

        // MIA → São Paulo (GRU)
        Flight(id: UUID(), airline: "LATAM Airlines", flightNumber: "LA 8180",
               departureAirport: "MIA", arrivalAirport: "GRU",
               departureTime: date(hoursFromNow: 40), arrivalTime: date(hoursFromNow: 49),
               price: 2800, pointsCost: 82000, cabinClass: .business, status: .scheduled),
        Flight(id: UUID(), airline: "American Airlines", flightNumber: "AA 953",
               departureAirport: "MIA", arrivalAirport: "GRU",
               departureTime: date(hoursFromNow: 36), arrivalTime: date(hoursFromNow: 45),
               price: 750, pointsCost: 34000, cabinClass: .economy, status: .scheduled),

        // SEA → Reykjavik (KEF)
        Flight(id: UUID(), airline: "Icelandair", flightNumber: "FI 680",
               departureAirport: "SEA", arrivalAirport: "KEF",
               departureTime: date(hoursFromNow: 44), arrivalTime: date(hoursFromNow: 52.5),
               price: 580, pointsCost: 25000, cabinClass: .economy, status: .scheduled),
        Flight(id: UUID(), airline: "Delta Air Lines", flightNumber: "DL 208",
               departureAirport: "SEA", arrivalAirport: "KEF",
               departureTime: date(hoursFromNow: 42), arrivalTime: date(hoursFromNow: 50),
               price: 2400, pointsCost: 70000, cabinClass: .business, status: .scheduled),

        // JFK → Bali (DPS)
        Flight(id: UUID(), airline: "Singapore Airlines", flightNumber: "SQ 25",
               departureAirport: "JFK", arrivalAirport: "DPS",
               departureTime: date(hoursFromNow: 48), arrivalTime: date(hoursFromNow: 68),
               price: 4500, pointsCost: 130000, cabinClass: .business, status: .scheduled),

        // LAX → Marrakech (RAK)
        Flight(id: UUID(), airline: "Air France", flightNumber: "AF 69",
               departureAirport: "LAX", arrivalAirport: "RAK",
               departureTime: date(hoursFromNow: 32), arrivalTime: date(hoursFromNow: 46),
               price: 1200, pointsCost: 52000, cabinClass: .economy, status: .scheduled),
    ]
}
```

**Step 2: Update `seedTripsAndBookings()` to use dynamic dates and link UA 412**

The Rome trip should be upcoming (start in ~5 days). The flight booking for UA 412 should reference `flights[0].id` so the Flighty card can find it. The key change is making trip dates relative to now and linking the booking's `sourceId` to the actual flight UUID.

After `seedFlights()` runs, capture the UA 412 flight ID:

```swift
// In seedTripsAndBookings(), after trips are created:
// Link flight booking to actual UA 412 flight
let ua412Id = flights.first(where: { $0.flightNumber == "UA 412" })?.id
// Use ua412Id as sourceId in the Rome flight booking
```

Update trip dates to relative:
- Rome: starts in 5 days, ends in 11 days
- Tokyo: starts in 30 days, ends in 40 days
- Mexico City: completed (60 days ago)
- Paris: starts in 50 days, ends in 57 days

**Step 3: Build and verify**

```bash
xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5
```

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/Services/Server/DataStore.swift
git commit -m "feat: make flight times dynamic relative to now

Flights are computed from Date() so the demo always feels live.
UA 412 departs in ~6h, DL 178 is in-flight, AZ 621 just landed."
```

---

### Task 3: Make DataStore Flight Times Dynamic (Vapor API)

**Files:**
- Modify: `DCETravelAPI/Sources/App/DataStore.swift`

**Step 1: Apply the same dynamic flight time changes**

Mirror the exact same `seedFlights()` and `seedTripsAndBookings()` changes from Task 2 into the Vapor server's DataStore. The code is nearly identical.

**Step 2: Build Vapor**

```bash
cd DCETravelAPI && swift build 2>&1 | tail -5
```

**Step 3: Commit**

```bash
git add DCETravelAPI/Sources/App/DataStore.swift
git commit -m "feat: mirror dynamic flight times in Vapor DataStore"
```

---

### Task 4: Enrich Flight Status API Endpoint

**Files:**
- Modify: `DCETravel/DCETravel/Services/Server/Handlers/FlightHandler.swift`
- Modify: `DCETravelAPI/Sources/App/Controllers/FlightController.swift`

**Step 1: Create enriched FlightStatusResponse**

Update the status response struct to include gate, terminal, baggage claim, delay info, and a computed status based on current time:

```swift
struct FlightStatusResponse: Codable {  // or Content for Vapor
    let flightNumber: String
    let airline: String
    let departureAirport: String
    let arrivalAirport: String
    let status: Flight.FlightStatus
    let departureTime: Date
    let arrivalTime: Date
    let gate: String?
    let terminal: String?
    let baggageClaim: String?
    let delayMinutes: Int?
    let progressPercent: Double?  // 0.0-1.0 for in-flight progress
}
```

**Step 2: Add status simulation logic**

In the `status()` handler, compute live status from time:

```swift
func computeLiveStatus(for flight: Flight) -> (status: Flight.FlightStatus, delayMinutes: Int?, progress: Double?) {
    let now = Date()
    let timeToDeparture = flight.departureTime.timeIntervalSince(now)
    let totalFlightTime = flight.arrivalTime.timeIntervalSince(flight.departureTime)
    let timeInFlight = now.timeIntervalSince(flight.departureTime)

    // Deterministic delay: ~15% of flights, seeded by flight ID
    let hash = abs(flight.flightNumber.hashValue)
    let hasDelay = hash % 7 == 0  // ~14% chance
    let delayMinutes = hasDelay ? ((hash % 4) + 1) * 15 : 0  // 15, 30, 45, or 60 min

    if flight.status == .cancelled { return (.cancelled, nil, nil) }

    if timeToDeparture > 3 * 3600 {
        // More than 3h to departure
        return (delayMinutes > 0 ? .delayed : .scheduled, delayMinutes > 0 ? delayMinutes : nil, nil)
    } else if timeToDeparture > 45 * 60 {
        // 3h to 45min: check-in open
        return (.checkIn, delayMinutes > 0 ? delayMinutes : nil, nil)
    } else if timeToDeparture > 15 * 60 {
        // 45min to 15min: boarding
        return (.boarding, delayMinutes > 0 ? delayMinutes : nil, nil)
    } else if timeToDeparture > 0 {
        // Last 15 min: still boarding
        return (.boarding, nil, nil)
    } else if timeInFlight < totalFlightTime {
        // In the air
        let progress = min(max(timeInFlight / totalFlightTime, 0), 1.0)
        return (.inFlight, nil, progress)
    } else {
        // Arrived
        return (.landed, nil, 1.0)
    }
}
```

Apply this in both FlightHandler (iOS embedded) and FlightController (Vapor).

**Step 3: Build both**

```bash
xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5
cd DCETravelAPI && swift build 2>&1 | tail -5
```

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/Services/Server/Handlers/FlightHandler.swift DCETravelAPI/Sources/App/Controllers/FlightController.swift
git commit -m "feat: enrich flight status with live simulation

Status computed from current time vs departure/arrival.
Includes gate, terminal, delay, and in-flight progress."
```

---

### Task 5: Update FlightServiceProtocol and APIFlightService

**Files:**
- Modify: `DCETravel/DCETravel/Services/Protocols/FlightServiceProtocol.swift`
- Modify: `DCETravel/DCETravel/Services/API/APIFlightService.swift`

**Step 1: Add a FlightStatusInfo model**

Create a response model that matches the enriched status endpoint:

```swift
struct FlightStatusInfo: Codable {
    let flightNumber: String
    let airline: String
    let departureAirport: String
    let arrivalAirport: String
    let status: Flight.FlightStatus
    let departureTime: Date
    let arrivalTime: Date
    let gate: String?
    let terminal: String?
    let baggageClaim: String?
    let delayMinutes: Int?
    let progressPercent: Double?
}
```

**Step 2: Add method to protocol**

```swift
protocol FlightServiceProtocol {
    func searchFlights(from: String, to: String, date: Date) async -> [Flight]
    func bookFlight(_ flight: Flight) async -> Booking
    func getFlightStatus(flightId: UUID) async -> Flight
    func getLiveFlightStatus(flightId: UUID) async -> FlightStatusInfo?  // NEW
}
```

**Step 3: Implement in APIFlightService**

```swift
func getLiveFlightStatus(flightId: UUID) async -> FlightStatusInfo? {
    return try? await client.get("/api/v1/flights/\(flightId)/status")
}
```

**Step 4: Add default implementation or update MockFlightService if it exists**

**Step 5: Build and commit**

```bash
git add DCETravel/DCETravel/Services/Protocols/FlightServiceProtocol.swift DCETravel/DCETravel/Services/API/APIFlightService.swift DCETravel/DCETravel/Models/FlightStatusInfo.swift
git commit -m "feat: add getLiveFlightStatus to flight service protocol"
```

---

### Task 6: Create FlightStatusCard SwiftUI Component

**Files:**
- Create: `DCETravel/DCETravel/Views/Components/FlightStatusCard.swift`

**Step 1: Build the Flighty-style card**

Create a new SwiftUI view following the dark luxury design system:

```swift
import SwiftUI

struct FlightStatusCard: View {
    let flight: Flight
    let statusInfo: FlightStatusInfo?
    let onTap: () -> Void

    // Uses dark luxury design: cardBackground, glassBorder, gold accents
    // Layout:
    // - Top row: airplane icon + airline flight number ... status badge
    // - Middle: route visualization (LAX ●━━━✈━━━● FCO) with progress
    // - Bottom row: DEPARTS / ARRIVES / GATE columns
    // - Footer: Terminal · Status text · Duration
}
```

Key design elements:
- Background: `DCEColors.cardBackground` with `glassBorder` stroke
- Status badge: colored pill (gold for scheduled, green for boarding, copper for in-flight, success for landed)
- Route progress: horizontal line with airplane icon positioned at `progressPercent`
- Gate/terminal in gold when assigned
- Dark shadows for depth
- Subtle animation on the airplane icon when in-flight

**Step 2: Build**

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/Components/FlightStatusCard.swift
git commit -m "feat: add Flighty-style flight status card component"
```

---

### Task 7: Integrate FlightStatusCard into HomeView

**Files:**
- Modify: `DCETravel/DCETravel/ViewModels/HomeViewModel.swift`
- Modify: `DCETravel/DCETravel/Views/Home/HomeView.swift`

**Step 1: Add flight status data to HomeViewModel**

```swift
// Add published properties:
@Published var bookedFlight: Flight?
@Published var flightStatusInfo: FlightStatusInfo?

// In loadData():
// Find the booked flight for the upcoming trip (by matching sourceId in bookings)
if let trip = upcomingTrip {
    let flightBooking = appState.bookings.first(where: {
        $0.tripId == trip.id && $0.type == .flight && $0.status == .confirmed
    })
    if let sourceId = flightBooking?.sourceId {
        bookedFlight = // fetch flight by sourceId
        flightStatusInfo = await appState.services.flights.getLiveFlightStatus(flightId: sourceId)
    }
}
```

**Step 2: Add FlightStatusCard to HomeView**

Insert after the hero card, before quick actions:

```swift
// Flight status card
if let flight = viewModel.bookedFlight {
    FlightStatusCard(
        flight: flight,
        statusInfo: viewModel.flightStatusInfo
    ) {
        if let trip = viewModel.upcomingTrip {
            router.navigate(to: .chat(tripId: trip.id))
        }
    }
    .padding(.horizontal, 20)
    .opacity(appeared ? 1 : 0)
    .offset(y: appeared ? 0 : 14)
}
```

**Step 3: Build and verify**

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/ViewModels/HomeViewModel.swift DCETravel/DCETravel/Views/Home/HomeView.swift
git commit -m "feat: integrate flight status card on Home screen

Shows Flighty-style card below hero when user has a booked flight.
Displays live status, gate, terminal, and in-flight progress."
```

---

### Task 8: Generate App Icon

**Files:**
- Create: `DCETravel/DCETravel/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Create: `DCETravel/DCETravel/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- Create: `mockup/app-icon.html` (temporary, for generation)

**Step 1: Create HTML with the icon design**

Create an HTML file that renders a 1024x1024 canvas:
- Deep navy (#0A1628) background filling the full square
- Gold (#C9A96E) to copper (#C26A2F) gradient diamond (rotated square) centered
- Diamond size: ~55% of icon width
- Thin gold compass line through the vertical axis of the diamond
- No rounded corners in the image (iOS applies them automatically)

**Step 2: Screenshot with Playwright at 1024x1024**

```bash
# Start server if not running
python3 -m http.server 8888 --directory mockup &
```

Use Playwright to navigate to `http://localhost:8888/app-icon.html`, resize viewport to 1024x1024, take a screenshot.

**Step 3: Create AppIcon.appiconset/Contents.json**

Modern Xcode (14+) supports a single 1024x1024 image:

```json
{
  "images": [
    {
      "filename": "AppIcon.png",
      "idiom": "universal",
      "platform": "ios",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}
```

**Step 4: Move screenshot to asset catalog**

```bash
mkdir -p DCETravel/DCETravel/Assets.xcassets/AppIcon.appiconset
cp mockup/screenshots/app-icon.png DCETravel/DCETravel/Assets.xcassets/AppIcon.appiconset/AppIcon.png
```

**Step 5: Build and verify**

**Step 6: Commit**

```bash
git add DCETravel/DCETravel/Assets.xcassets/AppIcon.appiconset/ mockup/app-icon.html
git commit -m "feat: add gold-diamond-on-navy app icon

1024x1024 icon with gold gradient diamond on deep navy background.
Generated via SVG/Playwright, auto-scaled by iOS."
```

---

### Task 9: Configure Personal Phone Deployment

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Document deployment steps in CLAUDE.md**

Add a new section to CLAUDE.md after the Railway deployment section:

```markdown
## Running on Personal iPhone

### Prerequisites
- iPhone connected via USB or on same WiFi network
- Apple ID signed in to Xcode (Xcode > Settings > Accounts)

### Setup Steps
1. Open `DCETravel/DCETravel.xcodeproj` in Xcode
2. Select the **DCETravel** target > **Signing & Capabilities**
3. Change **Team** to your Personal Team (your Apple ID)
4. If the bundle identifier `com.dce.travel` conflicts, change it to something unique (e.g., `com.yourname.dcetravel`)
5. Select your iPhone as the build destination (not simulator)
6. Build & Run (Cmd+R)
7. On first install, go to iPhone **Settings > General > VPN & Device Management** and trust your developer certificate

### API Connection
The Xcode scheme already has `API_BASE_URL=https://travel-production-d172.up.railway.app` configured. Your iPhone will connect to the Railway backend over the internet — no local server needed.

### Notes
- Personal Team signing: app expires after 7 days, re-run from Xcode to renew
- The app requires iOS 17.0+
- All data is served from Railway (no local dependencies)
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add personal iPhone deployment instructions to CLAUDE.md"
```

---

### Task 10: Final Build, Redeploy, and Push

**Step 1: Full clean build**

```bash
xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' clean build 2>&1 | tail -10
```

Expected: BUILD SUCCEEDED

**Step 2: Build Vapor for Railway**

```bash
cd DCETravelAPI && swift build -c release 2>&1 | tail -5
```

**Step 3: Push to GitHub**

```bash
git push origin main
```

**Step 4: Redeploy to Railway**

```bash
railway up --service Travel
```

Wait for deployment, verify health:

```bash
curl https://travel-production-d172.up.railway.app/api/v1/health
```
