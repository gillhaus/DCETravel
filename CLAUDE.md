# DCE Travel — AI-Powered Travel Concierge

## Quick Start

```bash
# iOS app — open in Xcode and run (scheme has env vars pre-configured)
open DCETravel/DCETravel.xcodeproj

# Vapor API — run locally
cd DCETravelAPI && swift run
# → http://localhost:8080/api/v1/health

# Deploy to Railway
railway up --service Travel
```

## Live URLs

- **API**: https://travel-production-d172.up.railway.app
- **Health**: https://travel-production-d172.up.railway.app/api/v1/health
- **Swagger Docs**: https://travel-production-d172.up.railway.app/docs/index.html
- **GitHub**: https://github.com/gillhaus/DCETravel

## Repository Structure

```
DCETravel/           iOS app (SwiftUI, MVVM, 102 Swift files)
DCETravelAPI/        Vapor 4 API server (26 Swift files)
Dockerfile           Multi-stage Docker build for Railway
railway.toml         Railway deployment config
CLAUDE.md            This file
```

## iOS App (DCETravel/)

### Build & Run

```bash
# Command line
xcodebuild -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Or open in Xcode and press Cmd+R
open DCETravel/DCETravel.xcodeproj
```

### Xcode Scheme Environment Variables

The shared scheme (`DCETravel.xcscheme`) has these pre-configured:

| Variable | Value | Purpose |
|----------|-------|---------|
| `API_BASE_URL` | `https://travel-production-d172.up.railway.app` | Remote API (remove to use embedded localhost server) |
| `ANTHROPIC_API_KEY` | *(add yours)* | Enables Claude-powered chat (without it, falls back to local intent-based agent) |

To edit: **Product > Scheme > Edit Scheme > Run > Arguments > Environment Variables**

To get an Anthropic API key: https://console.anthropic.com/settings/keys

### Architecture

- **SwiftUI + MVVM** with service protocol pattern
- **ServiceContainer** — `.mock` mode (no server) or `.local(APIClient)` mode (HTTP API)
- **Embedded HTTP server** via `NWListener` (Network framework) — used when no `API_BASE_URL` is set
- **Remote API** — when `API_BASE_URL` is set, connects to Railway/Vapor server instead
- **AI Chat** — Claude tool-use with 18 tools (search, book, navigate), or local intent-based agent as fallback
- **Social Feed** — dynamic home page with trip countdowns, booking alerts, AI suggestions, price alerts
- **Flight Status** — Flighty-style live flight status card on Home screen with simulated real-time progression
- **LLM Navigation** — Claude can navigate users between screens via `pendingNavigation` pattern

### Key Files

| File | Purpose |
|------|---------|
| `DCETravelApp.swift` | App entry — checks `API_BASE_URL`, starts LocalServer or connects remote |
| `AppState.swift` | Observable state: user, trips, bookings, chat messages per trip |
| `ServiceContainer.swift` | DI container — `.mock` or `.local(APIClient)` mode |
| `DataStore.swift` | In-memory seed data with dynamic flight times relative to Date() |
| `LLMChatService.swift` | Claude API integration — 18 tools, tool-use loop, rich content building |
| `ClaudeToolSchemas.swift` | Tool definitions (search, book, navigate, points, trips) |
| `NavigationBridge.swift` | LLM-to-UI navigation bridge (pendingNavigation → router) |
| `AgentChatService.swift` | Fallback agent — intent parsing without LLM |
| `HomeViewModel.swift` | Home page data: upcoming trip, countdown, bookings, AI suggestion, points, flight status |
| `FlightStatusCard.swift` | Flighty-style flight status card with live progress, gate, terminal |
| `FeedViewModel.swift` | Social feed generation (countdowns, bookings, suggestions, weather, prices) |
| `ConciergeHeroCard.swift` | Hero trip card with AsyncImage, gradient overlay, countdown |
| `ConciergeHighlightCard.swift` | Highlight card with 3 variants: booking, AI suggestion, points |
| `ProfileSheetView.swift` | Profile modal sheet with user info, tier, menu navigation |
| `FeedCard.swift` | Feed card component with 7 card types and accent colors |
| `HomeView.swift` | Concierge home: chat CTA, hero card, flight status, quick actions, highlights, inspiration |
| `ChatView.swift` | Chat UI with rich content, typing indicator, suggested actions, navigation |
| `ChatViewModel.swift` | Chat state, message persistence, navigation intent mapping |
| `ContentView.swift` | Root navigation — LanderView → HomeView flow |
| `AppRouter.swift` | NavigationPath routing with AppRoute enum |

### Navigation Routes

```swift
enum AppRoute {
    case home, actionsGrid, tripSuggestions, postTrip
    case chat(tripId:), checkout(tripId:), confirmation(tripId:)
    case itemCheckout(tripId:, item:), bookingList(tripId:)
    case searchResults(tripId:, category:), onTrip(tripId:), tripReview(tripId:)
}
```

### Conventions

- All service protocols use `async` (no throws)
- API services use `try?` with fallback values for resilience
- Models conform to `Codable` + `Identifiable`
- JSON dates use ISO8601 via `JSONEncoder.apiEncoder` / `JSONDecoder.apiDecoder`
- Router uses path segment matching with `:param` syntax
- Use `DCEColors` and `DCEFonts` for design consistency
- Agent tools return JSON strings; rich content is built from tool results
- Navigation from LLM uses `pendingNavigation` pattern (set intent → view observes → navigates after 1s delay)

### Design System — Luxury Dark Mode

The app uses a dark luxury aesthetic: deep navy backgrounds, gold/copper accents, glass-morphism cards, editorial serif + sans-serif typography.

**Color palette** (defined in `DCEColors.swift`):
- Backgrounds: `navy` (#0A1628), `cardBackground` (#14243D), `cardBackgroundElevated` (#1A2B4A)
- Accents: `gold` (#C9A96E), `goldLight` (#D4B87A), `goldDim` (gold @ 15%), `copper` (#C26A2F)
- Glass-morphism: `glass` (white @ 4%), `glassBorder` (white @ 8%)
- Text: `primaryText` (#F0EDE8), `secondaryText` (#8B9BB4), `tertiaryText` (#5A6A82)
- Status: `success` (#3DD68C), `warning` (#F5A623), `error` (#E85454)

**Key patterns:**
- Cards use `cardBackground` with `glassBorder` stroke overlay and dark shadows (`.black.opacity(0.2+)`)
- Primary buttons use gold-to-copper gradient with navy text
- Icons/accents use `gold` (not `navy` — navy is the background)
- Chat: agent bubbles in `agentBubble` (#14243D), user bubbles with gold tint
- Image overlays use navy-based gradients (not black)
- Design mockups: `mockup/home-dark.html`, `mockup/chat-dark.html`

## Vapor API Server (DCETravelAPI/)

### Run Locally

```bash
cd DCETravelAPI
swift package resolve   # first time only
swift run App
# → http://localhost:8080
# → Swagger docs: http://localhost:8080/docs/index.html
```

### Build

```bash
cd DCETravelAPI
swift build              # debug
swift build -c release   # production
```

### API Endpoints

All routes prefixed with `/api/v1/`:

| Resource | Method | Path | Description |
|----------|--------|------|-------------|
| Health | GET | `/health` | Server health check |
| Flights | POST | `/flights/search` | Search (origin, destination, cabin, price) |
| Flights | GET | `/flights/:id` | Get flight details |
| Flights | GET | `/flights/:id/status` | Live flight status (simulated: gate, terminal, delay, progress) |
| Flights | POST | `/flights/:id/book` | Book flight |
| Hotels | POST | `/hotels/search` | Search (destination, price, rating, tier) |
| Hotels | GET | `/hotels/:id` | Get hotel details |
| Hotels | POST | `/hotels/:id/book` | Book hotel |
| Hotels | POST | `/hotels/:id/points-boost` | Apply 33% points discount |
| Cars | POST | `/cars/search` | Search (location, type, price) |
| Cars | GET | `/cars/:id` | Get car details |
| Cars | POST | `/cars/:id/book` | Book car rental |
| Restaurants | POST | `/restaurants/search` | Search (location, cuisine, price) |
| Restaurants | GET | `/restaurants/:id` | Get restaurant details |
| Restaurants | GET | `/restaurants/:id/availability` | Check availability |
| Restaurants | POST | `/restaurants/:id/reserve` | Reserve table |
| Bookings | GET | `/bookings` | List (filter: tripId, type, status) |
| Bookings | GET | `/bookings/:id` | Get booking details |
| Bookings | PUT | `/bookings/:id` | Modify booking |
| Bookings | DELETE | `/bookings/:id` | Cancel (refunds points) |
| Trips | GET | `/trips` | List all trips |
| Trips | POST | `/trips` | Create trip |
| Trips | GET | `/trips/:id` | Get trip details |
| Trips | PUT | `/trips/:id` | Update trip |
| Trips | POST | `/trips/:id/itinerary` | Set itinerary |
| Trips | GET | `/trips/:id/bookings` | Get trip bookings |
| Destinations | GET | `/destinations/search?query=` | Search destinations |
| Destinations | GET | `/destinations/inspiration` | Trending/recommended |
| Destinations | GET | `/destinations/:id` | Get destination details |
| Points | GET | `/points/balance` | Balance, tier, value |
| Points | POST | `/points/calculate-value` | Points to USD |
| Points | POST | `/points/apply-boost` | 33% boost calc |
| User | GET | `/user/profile` | User profile |
| User | GET | `/user/preferences` | Travel preferences |

### Swagger / OpenAPI

- Swagger UI: `/docs/index.html` (served via Vapor FileMiddleware from `Public/` directory)
- OpenAPI spec: `/docs/openapi.yaml`
- The Dockerfile copies `Public/` into the container for production serving

### Server Structure

```
DCETravelAPI/
├── Package.swift              # Vapor 4.89+ dependency
├── Public/docs/               # Swagger UI + OpenAPI spec
│   ├── index.html
│   └── openapi.yaml
├── Sources/App/
│   ├── entrypoint.swift       # @main entry point
│   ├── configure.swift        # CORS, FileMiddleware, JSON config, port
│   ├── routes.swift           # /api/v1/ group, health endpoint, controller registration
│   ├── JSONCoders.swift       # ISO8601 encoder/decoder extensions
│   ├── DataStore.swift        # In-memory data store (same seed data as iOS)
│   ├── Models/                # 10 model files (ported from iOS + Content conformance)
│   └── Controllers/           # 9 controllers (Flight, Hotel, Restaurant, Car, Booking, Trip, Destination, Points, User)
└── Tests/AppTests/
    └── AppTests.swift         # Health check test
```

## Deployment (Railway)

### Current Deployment

- **Project**: Travel
- **Service**: Travel
- **Region**: us-west2
- **Domain**: `travel-production-d172.up.railway.app`

### Deploy Updates

```bash
cd /Users/oronhaus/Development/Travel
railway up --service Travel
```

### Dockerfile

Multi-stage build: compiles in `swift:5.9-jammy`, copies binary + Public/ to slim image.

### Railway Config (railway.toml)

```toml
[build]
dockerfilePath = "Dockerfile"

[deploy]
startCommand = "/app/App serve --env production --hostname 0.0.0.0"
healthcheckPath = "/api/v1/health"
```

### Switching iOS Between Local and Remote API

- **Remote (Railway)**: Set `API_BASE_URL=https://travel-production-d172.up.railway.app` in scheme
- **Local (embedded server)**: Remove or disable `API_BASE_URL` — app starts its own NWListener server

### Personal Phone Deployment

To run on a personal iPhone:
1. Set `DEVELOPMENT_TEAM` to your Apple ID team ID in the Xcode project (Signing & Capabilities)
2. Change the bundle identifier to something unique (e.g., `com.yourname.DCETravel`)
3. Ensure `API_BASE_URL` points to the Railway deployment (already configured in scheme)
4. Connect your iPhone, select it as the destination, and build/run

## Seed Data Summary

Flight times are **dynamic** — computed relative to `Date()` at app launch so the demo always feels live:
- **UA 412** (LAX→FCO): departs in ~6h — the Flighty card target
- **DL 178** (LAX→FCO): departed ~3h ago — in-flight example
- **AZ 621** (LAX→FCO): landed ~1h ago — recent arrival

| Category | Count | Examples |
|----------|-------|---------|
| Flights | 24 | LAX↔Rome, LAX↔Tokyo, JFK↔London, SFO↔Barcelona... |
| Hotels | 22 | Portrait Roma, Park Hyatt Tokyo, Four Seasons Paris... |
| Restaurants | 18 | Armando Al Pantheon, Sukiyabashi Jiro, Le Cinq... |
| Car Rentals | 16 | Hertz, Avis, Enterprise, Sixt across 6 cities |
| Destinations | 13 | Rome, Tokyo, Paris, Bali, Reykjavik, NYC, Cancun... |
| Trips | 4 | Rome (+5d), Tokyo (+30d), Mexico City (-60d), Paris (+50d) |
| Bookings | 8 | Flights, hotels, restaurants across trips |
| Themes | 3 | Roman history, Luxury shopping, Local hidden gems |

## Coding Guidelines

- Prefer editing existing files over creating new ones
- Keep services thin — business logic in ViewModels
- All new models must conform to `Codable` + `Identifiable`
- Use `DCEColors` and `DCEFonts` for design consistency
- Agent tools return JSON strings; rich content is built from tool results
- Navigation from LLM uses `pendingNavigation` pattern
- For Vapor controllers: implement `RouteCollection`, use `DataStore.shared`
- Thread-safe mutations in DataStore use `NSLock`
