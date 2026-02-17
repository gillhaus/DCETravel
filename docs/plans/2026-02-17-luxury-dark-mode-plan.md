# Luxury Dark Mode Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the DCE Travel app from light cream/white to a luxury dark navy/gold theme across every screen.

**Architecture:** The app uses a centralized `DCEColors`/`DCEStyles` design token system. ~80% of the visual change comes from updating these 2 files. The remaining 20% is view-specific hardcoded colors, gradients, and shadows that need individual attention.

**Tech Stack:** SwiftUI, iOS 17+, Xcode

**Design reference:** `mockup/home-dark.html` and `mockup/chat-dark.html` (open in browser at `http://localhost:8888/`)

---

### Task 1: Update DCEColors.swift — Core Color Tokens

**Files:**
- Modify: `DCETravel/DCETravel/Theme/DCEColors.swift`

**Step 1: Replace all color definitions**

Replace the entire `DCEColors` enum body (lines 3-34) with:

```swift
enum DCEColors {
    // Primary
    static let navy = Color(hex: "0A1628")
    static let copper = Color(hex: "C26A2F")

    // Gold accent system
    static let gold = Color(hex: "C9A96E")
    static let goldLight = Color(hex: "D4B87A")
    static let goldDim = Color(hex: "C9A96E").opacity(0.15)

    // Backgrounds
    static let warmBackground = Color(hex: "0A1628")
    static let creamBackground = Color(hex: "0F1D32")
    static let cardBackground = Color(hex: "14243D")
    static let cardBackgroundElevated = Color(hex: "1A2B4A")

    // Glass-morphism
    static let glass = Color.white.opacity(0.04)
    static let glassBorder = Color.white.opacity(0.08)

    // Chat
    static let agentBubble = Color(hex: "14243D")
    static let userBubble = Color(hex: "1A2B4A")

    // Status
    static let success = Color(hex: "3DD68C")
    static let warning = Color(hex: "F5A623")
    static let error = Color(hex: "E85454")

    // Text
    static let primaryText = Color(hex: "F0EDE8")
    static let secondaryText = Color(hex: "8B9BB4")
    static let tertiaryText = Color(hex: "5A6A82")

    // Points
    static let pointsBoostBackground = Color(hex: "14243D")
    static let pointsBoostAccent = Color(hex: "C9A96E")

    // Misc
    static let divider = Color.white.opacity(0.06)
    static let shimmer = Color(hex: "1A2B4A")
}
```

**Step 2: Build to verify no compile errors**

Run: `xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Theme/DCEColors.swift
git commit -m "feat: update color palette to luxury dark mode

Swap all color tokens from light cream/white to deep navy/gold dark theme.
This cascades to ~80% of views automatically via DCEColors references."
```

---

### Task 2: Update DCEStyles.swift — Buttons, Cards, Chips

**Files:**
- Modify: `DCETravel/DCETravel/Theme/DCEStyles.swift`

**Step 1: Update button styles and card modifier**

Replace the primary button background and text for dark mode contrast:

```swift
struct DCEPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [DCEColors.gold, DCEColors.copper],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DCESecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.gold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DCEColors.gold.opacity(0.4), lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct DCECopperButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DCEFonts.labelLarge())
            .foregroundColor(DCEColors.navy)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [DCEColors.gold, DCEColors.copper],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
```

Update card modifier for dark mode shadows:

```swift
struct DCECardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(DCEColors.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DCEColors.glassBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
```

Update chip style:

```swift
struct DCEChipStyle: ViewModifier {
    var isSelected: Bool = false

    func body(content: Content) -> some View {
        content
            .font(DCEFonts.labelMedium())
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? DCEColors.gold.opacity(0.2) : DCEColors.glass)
            .foregroundColor(isSelected ? DCEColors.gold : DCEColors.secondaryText)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? DCEColors.gold.opacity(0.3) : DCEColors.glassBorder, lineWidth: 1)
            )
    }
}
```

**Step 2: Build**

Run: `xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Theme/DCEStyles.swift
git commit -m "feat: update button/card/chip styles for dark luxury theme

Primary buttons now use gold-to-copper gradient. Cards have glass-morphism
borders. Chips use glass background with gold accent when selected."
```

---

### Task 3: Update HomeView.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Home/HomeView.swift`

**Step 1: Fix hardcoded colors**

Search for and replace these patterns throughout the file:
- Any `.background(Color.white)` → `.background(DCEColors.cardBackground)`
- Any `.background(.white)` → `.background(DCEColors.cardBackground)`
- Any `.foregroundColor(.white)` on dark elements → `.foregroundColor(DCEColors.primaryText)`
- Any `Color.white.opacity(...)` used for backgrounds → `DCEColors.glass` or `DCEColors.glassBorder`
- Any `.black.opacity(0.06)` shadows → `.black.opacity(0.2)` (darker shadows for dark mode)
- Any `navy.opacity(0.06)` or `navy.opacity(0.12)` borders → `DCEColors.glassBorder`
- The quick-action icon circles: change background to `DCEColors.cardBackground` with `DCEColors.glassBorder` overlay
- Section icon colors: use `DCEColors.gold` instead of `DCEColors.copper` for section icons

**Step 2: Build and verify**

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/Home/HomeView.swift
git commit -m "feat: update HomeView for dark luxury theme"
```

---

### Task 4: Update ConciergeHeroCard.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Components/ConciergeHeroCard.swift`

**Step 1: Darken the gradient overlay and add vignette**

- Change gradient overlay stops to use `DCEColors.navy` with opacities: transparent → 0.03 at 25% → 0.45 at 60% → 0.92 at 100%
- Add inner shadow for cinematic vignette: `.shadow(color: .black.opacity(0.3), radius: 40)` as an inset overlay
- Change countdown pill background to `DCEColors.navy.opacity(0.65)` with blur and gold border
- Change countdown number color to `DCEColors.gold`
- "Start planning" CTA: change to `DCEColors.gold` color
- Bottom row text: `DCEColors.secondaryText`
- Card background/shadow: darker shadow `.black.opacity(0.4)`

**Step 2: Build and verify**

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/Components/ConciergeHeroCard.swift
git commit -m "feat: update hero card with dark gradient and cinematic vignette"
```

---

### Task 5: Update ConciergeHighlightCard.swift and FeedCard.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Components/ConciergeHighlightCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/FeedCard.swift`

**Step 1: Update highlight cards**

- Card background: `DCEColors.cardBackground`
- Add glass border overlay: `DCEColors.glassBorder`
- Icon circle backgrounds: use accent color at 0.12 opacity (purple at 0.12, gold at 0.15, green at 0.12)
- Text: primary and secondary text colors already handled by DCEColors
- Chevron circle: `DCEColors.glass` background

**Step 2: Update feed cards similarly**

- Card background: `DCEColors.cardBackground`
- Border: accent color at 0.12 opacity
- Icon circle: accent at 0.15 opacity

**Step 3: Build and verify**

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/Views/Components/ConciergeHighlightCard.swift DCETravel/DCETravel/Views/Components/FeedCard.swift
git commit -m "feat: update highlight and feed cards for dark theme"
```

---

### Task 6: Update ChatView.swift, ChatBubble.swift, ChatInputBar.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Chat/ChatView.swift`
- Modify: `DCETravel/DCETravel/Views/Components/ChatBubble.swift`
- Modify: `DCETravel/DCETravel/Views/Components/ChatInputBar.swift`

**Step 1: ChatView background and header**

- Background: `DCEColors.warmBackground` (already mapped to dark navy)
- Header: dark background with gold back arrow
- Trip pill: `DCEColors.goldDim` background with gold text and border

**Step 2: ChatBubble — iMessage Dark style**

Agent bubbles:
- Background: `DCEColors.agentBubble` (= `#14243D`)
- Border: `DCEColors.glassBorder`
- Corner radius: 4pt top-left, 18pt others (square corner on agent side)

User bubbles:
- Background: `LinearGradient(colors: [DCEColors.gold.opacity(0.2), DCEColors.copper.opacity(0.2)], ...)`
- Border: `DCEColors.gold.opacity(0.15)`
- Corner radius: 18pt top-left, 4pt top-right, 18pt others

Rich content cards (hotel, flight, restaurant within chat):
- Background: `DCEColors.cardBackground` with glass border

**Step 3: ChatInputBar**

- Field background: `DCEColors.cardBackground`
- Field border: `DCEColors.glassBorder`, gold on focus
- Send button: gold-to-copper gradient, dark icon
- Placeholder text: `DCEColors.tertiaryText`

**Step 4: Build and verify**

**Step 5: Commit**

```bash
git add DCETravel/DCETravel/Views/Chat/ChatView.swift DCETravel/DCETravel/Views/Components/ChatBubble.swift DCETravel/DCETravel/Views/Components/ChatInputBar.swift
git commit -m "feat: update chat UI with iMessage Dark style

Agent bubbles in dark navy cards, user bubbles with gold tint gradient.
Input bar with glass-morphism field and gold send button."
```

---

### Task 7: Update LanderView.swift and ContentView.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Lander/LanderView.swift`
- Modify: `DCETravel/DCETravel/ContentView.swift`

**Step 1: LanderView**

- Background: `DCEColors.warmBackground`
- Title text: `DCEColors.primaryText`
- Subtitle: `DCEColors.secondaryText`
- CTA button: gold gradient (uses DCEPrimaryButtonStyle — already updated)
- Any shimmer/loading: already handled by DCEColors.shimmer

**Step 2: ContentView**

- Navigation bar appearance: configure for dark background
- Tint color: gold for navigation items

**Step 3: Build and verify**

**Step 4: Commit**

```bash
git add DCETravel/DCETravel/Views/Lander/LanderView.swift DCETravel/DCETravel/ContentView.swift
git commit -m "feat: update lander and root content view for dark theme"
```

---

### Task 8: Update ProfileSheetView.swift

**Files:**
- Modify: `DCETravel/DCETravel/Views/Home/ProfileSheetView.swift`

**Step 1: Dark profile sheet**

- Sheet background: `DCEColors.warmBackground`
- Avatar: gold-to-copper gradient ring
- Name/email: `DCEColors.primaryText` / `DCEColors.secondaryText`
- Menu items: `DCEColors.cardBackground` with glass border
- Tier badge: gold accent
- Dividers: `DCEColors.divider`

**Step 2: Build and verify**

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/Home/ProfileSheetView.swift
git commit -m "feat: update profile sheet for dark luxury theme"
```

---

### Task 9: Update Remaining Card Components

**Files:**
- Modify: `DCETravel/DCETravel/Views/Components/HotelCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/CarRentalCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/DestinationCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/RichMediaCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/TripProgressCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/UpdateAlertCard.swift`
- Modify: `DCETravel/DCETravel/Views/Components/PointsBoostBanner.swift`
- Modify: `DCETravel/DCETravel/Views/Components/ShimmerView.swift`
- Modify: `DCETravel/DCETravel/Views/Components/TagChip.swift`
- Modify: `DCETravel/DCETravel/Views/Components/QuickActionChip.swift`
- Modify: `DCETravel/DCETravel/Views/Components/ItineraryThemeCards.swift`

**Step 1: For each card, apply the pattern:**
- Replace any hardcoded `.white` / `Color.white` backgrounds → `DCEColors.cardBackground`
- Replace hardcoded `.black.opacity(small)` shadows → `.black.opacity(0.2+)`
- Add glass border overlay where cards use just shadow (no border currently)
- Ensure text colors reference DCEColors tokens not hardcoded values
- For gradient overlays on images: use navy-based gradients
- Price text: use `DCEColors.gold` for pricing emphasis
- PointsBoostBanner: gold accent on dark background
- ShimmerView: update to use dark shimmer color
- QuickActionChip/TagChip: glass-morphism style

**Step 2: Build and verify**

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/Components/
git commit -m "feat: update all card components for dark luxury theme"
```

---

### Task 10: Update Remaining Screen Views

**Files:**
- Modify: `DCETravel/DCETravel/Views/Checkout/CheckoutView.swift`
- Modify: `DCETravel/DCETravel/Views/Checkout/UnifiedCheckoutView.swift`
- Modify: `DCETravel/DCETravel/Views/Confirmation/ConfirmationView.swift`
- Modify: `DCETravel/DCETravel/Views/Search/SearchResultsView.swift`
- Modify: `DCETravel/DCETravel/Views/Booking/BookingListView.swift`
- Modify: `DCETravel/DCETravel/Views/Actions/ActionsGridView.swift`
- Modify: `DCETravel/DCETravel/Views/TripSuggestions/TripSuggestionsView.swift`
- Modify: `DCETravel/DCETravel/Views/TripSuggestions/TripReviewView.swift`
- Modify: `DCETravel/DCETravel/Views/OnTrip/OnTripView.swift`
- Modify: `DCETravel/DCETravel/Views/PostTrip/PostTripView.swift`

**Step 1: Apply the standard pattern to each screen:**
- Background: `DCEColors.warmBackground` (most already reference this)
- Any hardcoded white/cream → use DCEColors tokens
- Navigation bar: ensure dark appearance
- Shadows: darken for dark mode
- Borders: add glass-morphism borders where missing

**Step 2: Build the full app**

Run: `xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -5`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add DCETravel/DCETravel/Views/
git commit -m "feat: update all remaining screens for dark luxury theme"
```

---

### Task 11: Final Build Verification and Polish

**Step 1: Full clean build**

```bash
xcodebuild -project DCETravel/DCETravel.xcodeproj -scheme DCETravel -destination 'platform=iOS Simulator,name=iPhone 17 Pro' clean build 2>&1 | tail -10
```

Expected: BUILD SUCCEEDED with 0 errors, 0 warnings (or only pre-existing warnings)

**Step 2: Visual audit — scan every file for remaining light-mode artifacts**

Search for any remaining hardcoded light colors:
- `Color.white` (not inside opacity modifiers for glass effects)
- `Color(hex: "F8F6F3")` or `Color(hex: "F5F0EA")`
- `.background(.white)`

Fix any found instances.

**Step 3: Commit any fixes**

```bash
git add -A
git commit -m "fix: clean up remaining light-mode color artifacts"
```

---

### Task 12: Update CLAUDE.md and Push to GitHub

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Update CLAUDE.md**

Add to the design section:
- Note that the app now uses a dark luxury theme
- Update color references to reflect the new palette
- Mention the glass-morphism pattern for cards
- Reference the mockup files

**Step 2: Final commit and push**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with dark luxury theme documentation"
git push origin main
```
