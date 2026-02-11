import SwiftUI

enum DCEFonts {
    // Large display - serif style for hero titles
    static func displayLarge() -> Font {
        .system(size: 34, weight: .bold, design: .serif)
    }

    static func displayMedium() -> Font {
        .system(size: 28, weight: .bold, design: .serif)
    }

    static func displaySmall() -> Font {
        .system(size: 24, weight: .semibold, design: .serif)
    }

    // Headings - clean sans-serif
    static func headlineLarge() -> Font {
        .system(size: 22, weight: .bold, design: .default)
    }

    static func headlineMedium() -> Font {
        .system(size: 20, weight: .semibold, design: .default)
    }

    static func headlineSmall() -> Font {
        .system(size: 17, weight: .semibold, design: .default)
    }

    // Body
    static func bodyLarge() -> Font {
        .system(size: 17, weight: .regular, design: .default)
    }

    static func bodyMedium() -> Font {
        .system(size: 15, weight: .regular, design: .default)
    }

    static func bodySmall() -> Font {
        .system(size: 13, weight: .regular, design: .default)
    }

    // Labels
    static func labelLarge() -> Font {
        .system(size: 15, weight: .medium, design: .default)
    }

    static func labelMedium() -> Font {
        .system(size: 13, weight: .medium, design: .default)
    }

    static func labelSmall() -> Font {
        .system(size: 11, weight: .medium, design: .default)
    }

    // Caption
    static func caption() -> Font {
        .system(size: 12, weight: .regular, design: .default)
    }
}
