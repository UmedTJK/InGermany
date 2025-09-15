//
//  TagFilterView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI

struct TagFilterView: View {
    let tags: [String]
    var onTagSelected: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        onTagSelected(tag)
                    }) {
                        Text("#\(tag)")
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
