//
//  CategoryFilterButton.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//

//
//  CategoryFilterButton.swift
//  InGermany
//

import SwiftUI

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CategoryFilterButton(
        title: "Все",
        isSelected: true,
        systemImage: "star.fill",
        action: {}
    )
}
