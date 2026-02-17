# Flight Status, App Icon & Deploy Design

**Date**: 2026-02-17
**Status**: Approved

## Scope

Four features:
1. Live flight status card on Home screen (Flighty-style)
2. Dynamic seed data with simulated real-time status
3. Personal phone deployment via Railway backend
4. App icon — gold diamond on navy

---

## 1. Live Flight Status Card

A prominent card on the Home screen for your next/active booked flight. Shows airline, route, gate, terminal, departure countdown, and a visual progress bar when in-flight.

### Layout

```
┌─────────────────────────────────────────┐
│  ✈ UNITED UA 412              BOARDING  │
│  ─────────────────────────────────────  │
│  LAX ●━━━━━━━━━━━✈━━━━━━━━━━━━● FCO    │
│  Los Angeles          Rome Fiumicino    │
│  DEPARTS        ARRIVES        GATE     │
│  2:45 PM        11:00 AM+1    42B      │
│  Terminal 7 · On Time · 12h 15m         │
└─────────────────────────────────────────┘
```

### Status Progression

- T-24h to T-3h: `scheduled` — "On Time" or "Delayed Xm"
- T-3h to T-45m: `checkIn` — "Check-in Open"
- T-45m to T-15m: `boarding` — "Now Boarding · Gate XX"
- T-15m to departure: `departed`
- During flight: `inFlight` — progress bar with plane icon
- Near arrival: `landed`

### Placement

Below the hero trip card, above quick actions. Appears only when there's a booked flight within 48 hours or currently in progress.

### Data Model Additions (Flight)

- `gate: String?`
- `terminal: String?`
- `baggageClaim: String?`

---

## 2. Dynamic Seed Data

Flight times computed relative to "now" at app launch so the demo always feels live.

### Time Slots

| Flight | Offset | Status | Purpose |
|--------|--------|--------|---------|
| UA 412 LAX→FCO | +6h | scheduled | Flighty card target |
| DL 178 LAX→FCO | -3h | inFlight | In-flight example |
| AZ 621 LAX→FCO | -1h (landed) | landed | Recent arrival |
| EK 216 LAX→FCO | +26h | scheduled | Tomorrow option |
| NH 105 LAX→NRT | +14h | scheduled | Tokyo option |
| Remaining | Spread ±48h | Various | Realistic mix |

### Flight Status Simulator

Server-side `FlightStatusSimulator` that:
- Computes current status from `now` vs departure/arrival times
- Adds gate/terminal when status >= checkIn
- ~15% of flights get a realistic delay
- Deterministic (seeded by flight ID hash, not random)

### API Compatibility

`GET /flights/:id/status` returns enriched response. Architecture designed so swapping in AviationStack later means replacing one function.

---

## 3. Personal Phone + Railway

### What's Already Done
- Railway deployment: CORS open, 0.0.0.0, dynamic PORT
- iOS app reads `API_BASE_URL` from scheme env var
- Railway serves HTTPS (no ATS issues)

### What to Configure
- Xcode project: Personal Team code signing
- Unique bundle identifier (e.g., `com.yourname.DCETravel`)
- Redeploy Vapor API with updated seed data to Railway
- Document steps in CLAUDE.md

---

## 4. App Icon

### Design
- Background: Deep navy (#0A1628)
- Foreground: Gold (#C9A96E) diamond with gold-to-copper gradient
- Style: Flat/minimal luxury brand aesthetic
- Optional: thin compass line through center

### Technical
- Generate as SVG → screenshot at 1024x1024 via Playwright
- Single PNG in `AppIcon.appiconset/` (modern Xcode auto-scales)

---

## Files Affected

### New Files
- `AppIcon.appiconset/AppIcon.png` + `Contents.json`
- `Views/Components/FlightStatusCard.swift` — new Flighty-style card
- `Services/FlightStatusSimulator.swift` (Vapor) — status simulation

### Modified Files
- `Models/Flight.swift` — add gate, terminal, baggageClaim fields
- `DataStore.swift` (both iOS + Vapor) — dynamic relative times
- `FlightController.swift` — enriched status endpoint
- `HomeView.swift` / `HomeViewModel.swift` — show flight status card
- `DCETravelApp.swift` or project config — bundle ID for signing
- `CLAUDE.md` — personal phone deployment docs

---

## API Research (for future real API integration)

| Provider | Free Tier | Notes |
|----------|-----------|-------|
| AviationStack | 100-500 calls/mo | Simplest REST API, recommended first choice |
| AeroDataBox | 300-600 calls/mo | Cheapest paid ($5/mo for 3K calls) |
| AirLabs | 1,000 calls/mo | Most generous free tier |

Sources:
- https://aviationstack.com/pricing
- https://aerodatabox.com/pricing/
- https://www.flightapi.io/blog/flight-status-apis/
