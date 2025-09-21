import SwiftUI

struct AllArticlesSection: View {
    let favoritesManager: FavoritesManager // ПЕРВЫЙ параметр
    let articles: [Article]               // ВТОРОЙ параметр
    @EnvironmentObject private var ratingManager: RatingManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationManager.shared.translate("AllArticles")) // УБРАЛИ language параметр
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(articles) { article in
                        NavigationLink {
                            ArticleView(
                                article: article,
                                allArticles: articles,
                                favoritesManager: favoritesManager
                            )
                            .environmentObject(ratingManager)
                        } label: {
                            ArticleCardView(
                                favoritesManager: favoritesManager, // ИСПРАВЛЕНО порядок
                                article: article
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
