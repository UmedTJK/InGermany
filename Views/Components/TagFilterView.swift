//
//  TagFilterView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI

/// A horizontal scrollable view that displays a list of selectable tags as buttons.
struct TagFilterView: View {
    /// The collection of tags to be displayed in the filter view.
    let tags: [String]
    /// A closure called when a tag is selected, passing the selected tag as a parameter.
    var onTagSelected: (String) -> Void

    /// The main view layout displaying tags in a horizontally scrollable list.
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        onTagSelected(tag)
                    }) {
                        Text("#" + t(tag))
                            .font(.caption)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}
