import SwiftUI

struct ArticleCompactCard: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    // Размеры под горизонтальные списки
    private let cardWidth: CGFloat = 260
    private let imageHeight: CGFloat = 140

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Картинка из Bundle (Resources/Images)
            if let name = article.image,
               let uiImage = UIImage(named: name, in: .main, with: nil) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: imageHeight)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth, height: imageHeight)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(12)
            }

            // Заголовок
            Text(article.localizedTitle(for: selectedLanguage))
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Короткий анонс (2 строки)
            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: cardWidth)                // 📌 фиксируем ширину карточки
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}
