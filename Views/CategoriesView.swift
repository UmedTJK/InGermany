//
//  CategoriesView.swift
//  InGermany
//
//
//  CategoriesView.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct CategoriesView: View {
    @ObservedObject var favoritesManager: FavoritesManager
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var categories: [Category] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, tuple in
                    let category = tuple.element
                    NavigationLink(destination: ArticlesByCategoryView(category: category, favoritesManager: favoritesManager)) {
                        HStack {
                            Image(systemName: category.icon)
                                .font(.title3)
                                .foregroundColor(.blue)

                            Text(category.localizedName(for: selectedLanguage))
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .scaleEffect(1.0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                            value: categories.count
                        )
                    }
                    .buttonStyle(.plain)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .navigationTitle("Категории")
        .onAppear {
            categories = DataService.shared.loadCategories()
        }
    }
}

#Preview {
    NavigationView {
        CategoriesView(favoritesManager: FavoritesManager())
    }
}
