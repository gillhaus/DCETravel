# DCE Travel — AI-Powered Travel Concierge

## Project Overview

A full-stack AI travel concierge with an iOS SwiftUI app and Vapor API server. Features an agentic chat powered by Claude that can search flights, hotels, restaurants, cars, manage bookings, and navigate users between screens.

## Repository Structure

```
DCETravel/           iOS app (SwiftUI, MVVM)
DCETravelAPI/        Vapor 4 API server (Swift)
Dockerfile           Docker build for Railway deployment
railway.toml         Railway deployment config
```

## iOS App (DCETravel/)

### Build

```bash
xcodebuild -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

### Architecture

- **SwiftUI + MVVM** with service protocols
- **ServiceContainer** supports `.mock` and `.local(APIClient)` modes
- Embedded HTTP server via `NWListener` (Network framework) for simulator dev
- Supports remote API via `API_BASE_URL` environment variable
- AI chat agent with Claude tool-use (18 tools), intent parsing, multi-step planning
- Rich content: hotel cards, flight results, restaurant cards, booking confirmations, car rentals, destination results

### Key Files

| File | Purpose |
|------|---------|
| `DCETravelApp.swift` | App entry, starts LocalServer or connects to remote API |
| `AppState.swift` | Observable state: user, trips, bookings, chat messages |
| `ServiceContainer.swift` | Mode enum (.mock/.local), creates all services |
| `DataStore.swift` | In-memory data store with 20+ items per category |
| `AgentChatService.swift` | AI agent orchestrating tools via intent parsing |
| `LLMChatService.swift` | Claude API integration with 18 tools |
| `NavigationBridge.swift` | LLM-to-UI navigation bridge |
| `FeedViewModel.swift` | Social feed generation from AppState |

### Conventions

- All service protocols use `async` (no throws)
- API services use `try?` with fallback values
- Models are `Codable` + `Identifiable`
- JSON dates use ISO8601 via `JSONEncoder.apiEncoder` / `JSONDecoder.apiDecoder`
- Router uses path segment matching with `:param` syntax

## Vapor API Server (DCETravelAPI/)

### Run Locally

```bash
cd DCETravelAPI
swift run
# Server starts on http://localhost:8080
# API docs: http://localhost:8080/docs/
```

### Build

```bash
cd DCETravelAPI
swift build
```

### Endpoints

All routes under `/api/v1/`:

| Resource | Routes |
|----------|--------|
| Health | `GET /health` |
| Flights | `GET /flights`, `GET /flights/:id`, `GET /flights/:id/status`, `POST /flights/:id/book` |
| Hotels | `GET /hotels`, `GET /hotels/:id`, `POST /hotels/:id/book` |
| Cars | `GET /cars`, `POST /cars/:id/book` |
| Restaurants | `GET /restaurants`, `POST /restaurants/:id/reserve` |
| Bookings | `GET /bookings`, `DELETE /bookings/:id` |
| Trips | `GET /trips`, `GET /trips/:id` |
| Destinations | `GET /destinations` |
| Points | `GET /points` |
| User | `GET /user` |

### OpenAPI Docs

Swagger UI served at `/docs/` when running the server. OpenAPI spec at `/docs/openapi.yaml`.

## Deployment (Railway)

```bash
# Deploy to Railway
railway up

# The Dockerfile builds the Vapor server
# Health check: GET /api/v1/health
```

### Connect iOS to Remote API

Set `API_BASE_URL` environment variable in Xcode scheme:
```
API_BASE_URL=https://your-app.up.railway.app
```

## Coding Guidelines

- Prefer editing existing files over creating new ones
- Keep services thin — business logic in ViewModels
- All new models must conform to `Codable` + `Identifiable`
- Use `DCEColors` and `DCEFonts` for design consistency
- Agent tools return JSON strings; rich content is built from tool results
- Navigation from LLM uses `pendingNavigation` pattern (set intent → view observes → navigates after delay)
