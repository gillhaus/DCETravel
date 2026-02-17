# Luxury Dark Mode Redesign

**Date**: 2026-02-17
**Status**: Approved
**Scope**: Full app theme overhaul — every screen inherits dark luxury aesthetic

## Direction

Luxury Concierge dark mode. Deep navy backgrounds, gold/copper accents, editorial serif typography, glass-morphism cards, SVG icons throughout. Feels like a private travel advisor app — think Amex Centurion meets iMessage.

## Color Palette

| Token | Light (old) | Dark (new) | Usage |
|-------|-------------|------------|-------|
| `bgPrimary` | `#F8F6F3` | `#0A1628` | Main background |
| `bgCard` | `#FFFFFF` | `#14243D` | Card backgrounds |
| `bgCardElevated` | — | `#1A2B4A` | Hover/elevated cards |
| `gold` | `#C9A96E` | `#C9A96E` | Primary accent (unchanged) |
| `goldLight` | — | `#D4B87A` | Hover/light accent |
| `goldDim` | — | `rgba(201,169,110,0.15)` | Subtle gold backgrounds |
| `copper` | `#C26A2F` | `#C26A2F` | Secondary accent (unchanged) |
| `textPrimary` | `#1A2B4A` | `#F0EDE8` | Headlines, primary text |
| `textSecondary` | `#6B7280` | `#8B9BB4` | Body text, subtitles |
| `textTertiary` | `#9CA3AF` | `#5A6A82` | Hints, captions |
| `success` | `#2D8B4E` | `#3DD68C` | Confirmations |
| `warning` | `#E8A317` | `#F5A623` | Alerts |
| `error` | `#D64045` | `#E85454` | Errors |
| `divider` | `#E5E7EB` | `rgba(255,255,255,0.06)` | Separators |
| `glass` | — | `rgba(255,255,255,0.04)` | Glass-morphism fill |
| `glassBorder` | — | `rgba(255,255,255,0.08)` | Glass-morphism border |

### Chat-Specific Colors

| Token | Value | Usage |
|-------|-------|-------|
| `agentBubble` | `#14243D` | Concierge message bubbles |
| `userBubble` | Gold-tinted gradient | User message bubbles |

## Typography

No font changes — same Playfair Display (display/serif) + DM Sans/SF Pro (body/sans) pairing. Both work excellently on dark backgrounds. Key adjustment: text colors flip from dark-on-light to light-on-dark.

## Component Changes

### Cards
- Background: `#14243D` with `rgba(255,255,255,0.08)` border
- Hover: elevate to `#1A2B4A`, border brightens to `rgba(255,255,255,0.1)`
- Shadow: `0 4px 16px rgba(0,0,0,0.3)` on hover
- Accent bars remain (purple AI, gold points, green bookings)

### Hero Trip Card
- Add cinematic vignette: `inset box-shadow: 0 0 80px rgba(0,0,0,0.3)`
- Gradient overlay tuned for dark: transparent → `rgba(10,22,40,0.92)`
- Countdown pill: frosted glass with gold border

### Quick Actions
- Replace all emoji icons with stroked SVG icons
- Gold stroke color on dark card backgrounds
- Hover: gold-dim background fill

### Chat Bubbles (iMessage Dark)
- Agent: `#14243D` with glass border, square top-left corner
- User: gold-tinted gradient background, square top-right corner
- Rich content (hotel cards, etc.) as full-width dark cards
- Suggestion chips: glass-morphism with gold hover

### Navigation
- Dark backgrounds throughout
- Gold accent for active tab, back arrows, CTAs
- Profile avatar: gold-to-copper gradient ring

### Input Fields
- Dark card background (`#14243D`)
- Glass border, gold border on focus
- Gold gradient send button

## Screens Affected

Every screen inherits via DCEColors/DCEFonts/DCEStyles update:

1. **HomeView** — dark bg, greeting, hero card, quick actions, concierge cards, inspiration
2. **ChatView** — dark bubbles, rich cards, typing indicator, input bar
3. **ChatBubble** — agent/user bubble color swap
4. **ChatInputBar** — dark field, gold send button
5. **ProfileSheetView** — dark modal, gold accents
6. **LanderView** — dark welcome screen
7. **ConciergeHeroCard** — vignette, gradient overlay tuning
8. **ConciergeHighlightCard** — dark card, accent bars
9. **FeedCard** — dark card backgrounds, accent colors adjusted for dark
10. **HotelCard/FlightCard/RestaurantCard** — dark backgrounds, gold pricing
11. **All search/list views** — dark backgrounds, updated text colors
12. **Checkout/Confirmation views** — dark backgrounds, gold CTAs

## Files to Modify

### Core Theme (3 files)
- `DCEColors.swift` — All color definitions
- `DCEFonts.swift` — No changes needed
- `DCEStyles.swift` — Button styles, card modifiers

### Key Views (~15 files)
- `HomeView.swift`, `ChatView.swift`, `ChatBubble.swift`, `ChatInputBar.swift`
- `ConciergeHeroCard.swift`, `ConciergeHighlightCard.swift`, `FeedCard.swift`
- `ProfileSheetView.swift`, `LanderView.swift`, `ContentView.swift`
- `HotelCard.swift`, `FlightResultCard.swift`, `RestaurantCard.swift`
- `BookingCard.swift`, `DestinationCard.swift`

### Supporting Views (~10 files)
- Any view using `DCEColors.warmBackground`, `DCEColors.cardBackground`, `DCEColors.navy`
- Search result views, checkout views, confirmation views

## Mockups

- Home screen: `mockup/home-dark.html`
- Chat screen: `mockup/chat-dark.html`
- Screenshots: `mockup/screenshots/`
