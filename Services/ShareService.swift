// Services/ShareService.swift
import SwiftUI
import UIKit

/// Сервис для предоставления возможности шаринга статей через системное окно iOS.
@MainActor
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
    
    func showShareSheet(article: Article, selectedLanguage: String) {
        let shareText = generateFormattedText(article: article, selectedLanguage: selectedLanguage)
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
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
