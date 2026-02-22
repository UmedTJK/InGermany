//  Created by SUM TJK on 22.02.26.
//

import SwiftUI

struct HorizontalCarousel<Content: View>: View {
    var showsIndicators: Bool = false
    var spacing: CGFloat = DS.Spacing.carouselItem
    var contentInset: CGFloat = DS.Spacing.contentInset
    var verticalPadding: CGFloat = DS.Spacing.carouselVPad

    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView(.horizontal, showsIndicators: showsIndicators) {
            LazyHStack(spacing: spacing) {
                content()
            }
            .padding(.horizontal, contentInset)
            .padding(.vertical, verticalPadding)
        }
    }
}
