import SwiftUI

enum DS {}

extension DS {
    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 24

        static let section: CGFloat = 28
        static let contentInset: CGFloat = 16
        static let carouselItem: CGFloat = 16
        static let carouselVPad: CGFloat = 4
    }
}

// MARK: - Elevation
extension DS {
    /// Elevation tokens (shadow + stroke + optional material) to keep surfaces consistent.
    enum Elevation {
        struct CardSurface {
            // Stroke
            let strokeWidth: CGFloat

            // Key shadow (directional)
            let keyShadowRadius: CGFloat
            let keyShadowX: CGFloat
            let keyShadowY: CGFloat

            // Ambient shadow (soft)
            let ambientShadowRadius: CGFloat
            let ambientShadowX: CGFloat
            let ambientShadowY: CGFloat

            // Optional material background
            let material: Material

            func strokeColor(for colorScheme: ColorScheme) -> SwiftUI.Color {
                switch colorScheme {
                case .dark:
                    // Subtle top-edge lift in dark mode.
                    return SwiftUI.Color.white.opacity(0.10)
                default:
                    // Hairline border to define edges on light surfaces.
                    return SwiftUI.Color.black.opacity(0.06)
                }
            }

            func keyShadowColor(for colorScheme: ColorScheme) -> SwiftUI.Color {
                switch colorScheme {
                case .dark:
                    return SwiftUI.Color.black.opacity(0.35)
                default:
                    return SwiftUI.Color.black.opacity(0.10)
                }
            }

            func ambientShadowColor(for colorScheme: ColorScheme) -> SwiftUI.Color {
                switch colorScheme {
                case .dark:
                    return SwiftUI.Color.black.opacity(0.22)
                default:
                    return SwiftUI.Color.black.opacity(0.06)
                }
            }
        }

        /// Default premium card surface.
        static let card = CardSurface(
            strokeWidth: 1,
            keyShadowRadius: 10,
            keyShadowX: 0,
            keyShadowY: 6,
            ambientShadowRadius: 3,
            ambientShadowX: 0,
            ambientShadowY: 1,
            material: .ultraThinMaterial
        )
    }
}

// MARK: - Interaction
extension DS {
    enum Interaction {
        /// Subtle press scale for interactive surfaces (use with Reduce Motion awareness).
        static let pressScale: CGFloat = 0.99

        /// Shadow multiplier when pressed (keeps the same direction, but reduces depth).
        static let pressedShadowMultiplier: CGFloat = 0.65

        /// Stroke opacity boost when pressed (adds a bit of definition).
        static let pressedStrokeOpacityBoost: CGFloat = 0.06

        /// Default press animation duration.
        static let pressAnimationDuration: CGFloat = 0.16
    }
}

extension DS {
    enum Radius {
        static let card: CGFloat = 16
        static let media: CGFloat = 14
        static let badge: CGFloat = 10
        static let chip: CGFloat = 8
    }
}

extension DS {
    enum Color {
        static let background = SwiftUI.Color(.systemGroupedBackground)
        static let surface = SwiftUI.Color(.systemBackground)
        static let secondarySurface = SwiftUI.Color(.secondarySystemBackground)
        static let separator = SwiftUI.Color(.separator)

        static let textPrimary = SwiftUI.Color.primary
        static let textSecondary = SwiftUI.Color.secondary
    }
}

// MARK: - Typography
extension DS {
    enum Typography {
        static let sectionTitle: Font = .headline
        static let cardTitle: Font = .headline
        static let cardBody: Font = .subheadline
        static let meta: Font = .caption
        static let badge: Font = .caption2.weight(.semibold)
        static let chip: Font = .caption2
    }
}

// MARK: - Size
extension DS {
    enum Size {
        /// Standard minimum tappable target per HIG.
        static let hitTarget: CGFloat = 44

        /// Category list leading icon background circle.
        static let categoryIconCircle: CGFloat = 32

        /// Category list SF Symbol size.
        static let categoryIconSymbol: CGFloat = 16
    }
}
