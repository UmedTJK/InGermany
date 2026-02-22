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
