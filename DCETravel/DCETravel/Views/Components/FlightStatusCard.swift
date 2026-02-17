import SwiftUI

struct FlightStatusCard: View {
    let flight: Flight
    let statusInfo: FlightStatusInfo?
    let onTap: () -> Void

    // MARK: - Computed Properties

    private var effectiveStatus: Flight.FlightStatus {
        statusInfo?.status ?? flight.status
    }

    private var effectiveGate: String? {
        statusInfo?.gate ?? flight.gate
    }

    private var effectiveTerminal: String? {
        statusInfo?.terminal ?? flight.terminal
    }

    private var effectiveDelayMinutes: Int? {
        statusInfo?.delayMinutes
    }

    private var effectiveProgressPercent: Double? {
        statusInfo?.progressPercent
    }

    private var effectiveDepartureTime: Date {
        statusInfo?.departureTime ?? flight.departureTime
    }

    private var effectiveArrivalTime: Date {
        statusInfo?.arrivalTime ?? flight.arrivalTime
    }

    private var delayedDepartureTime: Date? {
        guard let delay = effectiveDelayMinutes, delay > 0 else { return nil }
        return effectiveDepartureTime.addingTimeInterval(TimeInterval(delay * 60))
    }

    private var delayedArrivalTime: Date? {
        guard let delay = effectiveDelayMinutes, delay > 0 else { return nil }
        return effectiveArrivalTime.addingTimeInterval(TimeInterval(delay * 60))
    }

    private var airlineShortName: String {
        let name = statusInfo?.airline ?? flight.airline
        // Return short form for common airlines
        switch name.lowercased() {
        case "united airlines": return "UNITED"
        case "delta air lines", "delta": return "DELTA"
        case "american airlines": return "AMERICAN"
        case "british airways": return "BRITISH AIRWAYS"
        case "air france": return "AIR FRANCE"
        case "ana", "all nippon airways": return "ANA"
        case "japan airlines", "jal": return "JAL"
        case "lufthansa": return "LUFTHANSA"
        case "iberia": return "IBERIA"
        case "emirates": return "EMIRATES"
        case "avianca": return "AVIANCA"
        case "icelandair": return "ICELANDAIR"
        case "garuda indonesia": return "GARUDA"
        default: return name.uppercased()
        }
    }

    private var flightNumber: String {
        statusInfo?.flightNumber ?? flight.flightNumber
    }

    private var statusText: String {
        if let delay = effectiveDelayMinutes, delay > 0, effectiveStatus == .delayed {
            return "Delayed \(delay)m"
        }
        return effectiveStatus.rawValue
    }

    private var footerStatusText: String {
        switch effectiveStatus {
        case .scheduled: return "On Time"
        case .checkIn: return "Check-in Open"
        case .boarding: return "Now Boarding"
        case .inFlight: return "In Flight"
        case .delayed:
            if let delay = effectiveDelayMinutes, delay > 0 {
                return "Delayed \(delay)m"
            }
            return "Delayed"
        case .landed: return "Landed"
        case .cancelled: return "Cancelled"
        }
    }

    private var durationText: String {
        let interval = effectiveArrivalTime.timeIntervalSince(effectiveDepartureTime)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    // MARK: - Status Badge Colors

    private var statusBadgeTextColor: Color {
        switch effectiveStatus {
        case .scheduled, .checkIn: return DCEColors.gold
        case .boarding, .landed: return DCEColors.success
        case .inFlight: return DCEColors.copper
        case .delayed: return DCEColors.warning
        case .cancelled: return DCEColors.error
        }
    }

    private var statusBadgeBackgroundColor: Color {
        switch effectiveStatus {
        case .scheduled, .checkIn: return DCEColors.gold.opacity(0.15)
        case .boarding, .landed: return DCEColors.success.opacity(0.15)
        case .inFlight: return DCEColors.copper.opacity(0.15)
        case .delayed: return DCEColors.warning.opacity(0.15)
        case .cancelled: return DCEColors.error.opacity(0.15)
        }
    }

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Top row: airline + flight number ... status badge
                topRow

                // Divider
                Rectangle()
                    .fill(DCEColors.divider)
                    .frame(height: 1)

                // Route visualization
                routeVisualization

                // Info columns: Departs / Arrives / Gate
                infoColumns

                // Footer line
                footerRow
            }
            .padding(20)
            .background(DCEColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(DCEColors.glassBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Top Row

    private var topRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "airplane")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(DCEColors.copper)
                Text("\(airlineShortName) \(flightNumber)")
                    .font(DCEFonts.labelMedium())
                    .foregroundColor(DCEColors.primaryText)
            }

            Spacer()

            // Status badge pill
            Text(statusText.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(statusBadgeTextColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(statusBadgeBackgroundColor)
                )
        }
    }

    // MARK: - Route Visualization

    private var routeVisualization: some View {
        VStack(spacing: 6) {
            // Route line with airplane
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let dotSize: CGFloat = 8
                let lineInset: CGFloat = dotSize / 2

                ZStack(alignment: .leading) {
                    // Background line
                    Rectangle()
                        .fill(DCEColors.tertiaryText.opacity(0.4))
                        .frame(height: 2)
                        .padding(.horizontal, lineInset)

                    // Progress line (filled portion)
                    if let progress = effectiveProgressPercent, progress > 0 {
                        Rectangle()
                            .fill(DCEColors.copper)
                            .frame(width: max(0, (totalWidth - dotSize) * progress + lineInset), height: 2)
                            .padding(.leading, lineInset)
                    }

                    // Departure dot
                    Circle()
                        .fill(DCEColors.primaryText)
                        .frame(width: dotSize, height: dotSize)

                    // Arrival dot
                    Circle()
                        .fill(effectiveStatus == .landed ? DCEColors.success : DCEColors.primaryText.opacity(0.4))
                        .frame(width: dotSize, height: dotSize)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    // Airplane icon positioned by progress
                    if let progress = effectiveProgressPercent, progress > 0, progress < 1 {
                        Image(systemName: "airplane")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(DCEColors.copper)
                            .offset(x: (totalWidth - dotSize) * progress - 7)
                    }
                }
                .frame(height: dotSize)
            }
            .frame(height: 8)

            // Airport codes and city names
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.departureAirport)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(DCEColors.primaryText)
                    Text(cityName(for: flight.departureAirport))
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(flight.arrivalAirport)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(DCEColors.primaryText)
                    Text(cityName(for: flight.arrivalAirport))
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.secondaryText)
                }
            }
        }
    }

    // MARK: - Info Columns

    private var infoColumns: some View {
        HStack(alignment: .top) {
            // Departs
            VStack(alignment: .leading, spacing: 4) {
                Text("DEPARTS")
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.tertiaryText)

                if let delayedTime = delayedDepartureTime {
                    // Show original time struck through, delayed time in warning
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formatTime(effectiveDepartureTime))
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.tertiaryText)
                            .strikethrough(color: DCEColors.tertiaryText)
                        Text(formatTime(delayedTime))
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.warning)
                    }
                } else {
                    Text(formatTime(effectiveDepartureTime))
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.primaryText)
                }
            }

            Spacer()

            // Arrives
            VStack(alignment: .center, spacing: 4) {
                Text("ARRIVES")
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.tertiaryText)

                if let delayedTime = delayedArrivalTime {
                    VStack(spacing: 2) {
                        Text(formatArrivalTime(effectiveArrivalTime))
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.tertiaryText)
                            .strikethrough(color: DCEColors.tertiaryText)
                        Text(formatArrivalTime(delayedTime))
                            .font(DCEFonts.bodySmall())
                            .foregroundColor(DCEColors.warning)
                    }
                } else {
                    Text(formatArrivalTime(effectiveArrivalTime))
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.primaryText)
                }
            }

            Spacer()

            // Gate
            VStack(alignment: .trailing, spacing: 4) {
                Text("GATE")
                    .font(DCEFonts.labelSmall())
                    .foregroundColor(DCEColors.tertiaryText)

                if let gate = effectiveGate {
                    Text(gate)
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.gold)
                } else {
                    Text("--")
                        .font(DCEFonts.bodySmall())
                        .foregroundColor(DCEColors.tertiaryText)
                }
            }
        }
    }

    // MARK: - Footer Row

    private var footerRow: some View {
        HStack(spacing: 0) {
            let parts = footerParts()
            ForEach(Array(parts.enumerated()), id: \.offset) { index, part in
                if index > 0 {
                    Text(" \u{00B7} ")
                        .font(DCEFonts.caption())
                        .foregroundColor(DCEColors.tertiaryText)
                }
                Text(part)
                    .font(DCEFonts.caption())
                    .foregroundColor(DCEColors.secondaryText)
            }
        }
    }

    // MARK: - Helpers

    private func footerParts() -> [String] {
        var parts: [String] = []
        if let terminal = effectiveTerminal {
            parts.append("Terminal \(terminal)")
        }
        parts.append(footerStatusText)
        parts.append(durationText)
        return parts
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    private func formatArrivalTime(_ date: Date) -> String {
        let calendar = Calendar.current
        let dayDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: effectiveDepartureTime), to: calendar.startOfDay(for: date)).day ?? 0
        let timeStr = formatTime(date)
        if dayDiff > 0 {
            return "\(timeStr)+\(dayDiff)"
        }
        return timeStr
    }

    private func cityName(for code: String) -> String {
        switch code {
        case "LAX": return "Los Angeles"
        case "FCO": return "Rome Fiumicino"
        case "NRT": return "Tokyo Narita"
        case "CDG": return "Paris CDG"
        case "LHR": return "London Heathrow"
        case "BCN": return "Barcelona"
        case "CUN": return "Cancun"
        case "GRU": return "São Paulo"
        case "KEF": return "Reykjavik"
        case "DPS": return "Bali Denpasar"
        case "RAK": return "Marrakech"
        case "JFK": return "New York JFK"
        case "SFO": return "San Francisco"
        case "ORD": return "Chicago O'Hare"
        case "SEA": return "Seattle"
        case "MIA": return "Miami"
        default: return code
        }
    }
}
