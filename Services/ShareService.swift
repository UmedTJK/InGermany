// Services/ShareService.swift
import SwiftUI
import UIKit

/// Сервис для предоставления возможности шаринга статей через системное окно iOS.
final class ShareService: ShareServiceProtocol {
    private let articleFormatter: ArticleFormatter
    private let localizationManager: LocalizationManager
    
    init(
        articleFormatter: ArticleFormatter,
        localizationManager: LocalizationManager
    ) {
        self.articleFormatter = articleFormatter
        self.localizationManager = localizationManager
    }
    
    // MARK: - ShareServiceProtocol Implementation
    
    func generatePlainText(article: Article, selectedLanguage: String) -> String {
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let readingTimeMinutes = articleFormatter.readingTime(article, for: selectedLanguage)
        let formattedReadingTime = formatReadingTime(readingTimeMinutes, language: selectedLanguage)
        
        return """
        \(title)
        
        \(content)
        
        \(localize("Время чтения", language: selectedLanguage)): \(formattedReadingTime)
        \(localize("Опубликовано", language: selectedLanguage)): \(articleFormatter.formattedCreatedDate(article, for: selectedLanguage))
        
        \(localize("Поделилось из", language: selectedLanguage)) InGermany App
        """
    }
    
    func generateFormattedText(article: Article, selectedLanguage: String) -> String {
        let title = article.localizedTitle(for: selectedLanguage)
        let content = article.localizedContent(for: selectedLanguage)
        let readingTimeMinutes = articleFormatter.readingTime(article, for: selectedLanguage)
        let formattedReadingTime = formatReadingTime(readingTimeMinutes, language: selectedLanguage)
        
        return """
        📖 \(title)
        
        \(content)
        
        ⏱️ \(localize("Время чтения", language: selectedLanguage)): \(formattedReadingTime)
        📅 \(localize("Опубликовано", language: selectedLanguage)): \(articleFormatter.formattedCreatedDate(article, for: selectedLanguage))
        
        📱 \(localize("Поделилось из", language: selectedLanguage)) InGermany App
        """
    }
    
    /// Возвращает элементы для системного шаринга. UI-презентация должна происходить в UI-слое (SwiftUI .sheet).
    func makeShareItems(article: Article, selectedLanguage: String) -> [Any] {
        let shareText = generateFormattedText(article: article, selectedLanguage: selectedLanguage)
        return [shareText]
    }

    /// Deprecated: презентация UI из сервиса запрещена (UIKit global). Используй `makeShareItems` + `ActivityView`.
    @available(*, deprecated, message: "UI presentation is handled by the UI layer. Use makeShareItems(...) and ActivityView in a .sheet.")
    func showShareSheet(article: Article, selectedLanguage: String) {
        assertionFailure("ShareService.showShareSheet is deprecated. Present ActivityView from the UI layer.")
    }
    
    // MARK: - Private Helpers
    
    private func formatReadingTime(_ minutes: Int, language: String) -> String {
        switch language {
        case "ru":
            return "\(minutes) мин."
        case "en":
            return "\(minutes) min"
        case "de":
            return "\(minutes) Min."
        case "tj":
            return "\(minutes) дақ."
        default:
            return "\(minutes) min"
        }
    }
    
    private func localize(_ key: String, language: String) -> String {
        localizationManager.getTranslation(key: key, language: language)
    }
}

/// SwiftUI wrapper для UIActivityViewController.
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // no-op
    }
}
