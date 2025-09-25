import SwiftUI

struct ArticleCompactCard: View {
    let article: Article
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @ObservedObject private var ratingManager = RatingManager.shared

    // Размеры карточки
    private let cardWidth: CGFloat = 320
    private let imageHeight: CGFloat = 280

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .multilineTextAlignment(.leading)

            // Короткий анонс (2 строки из начала статьи)
            Text(article.localizedContent(for: selectedLanguage))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Метаданные: рейтинг и время чтения
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    Text("\(ratingManager.rating(for: article.id))/5")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(article.formattedReadingTime(for: selectedLanguage))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: cardWidth) // 📌 фиксируем ширину карточки
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}
