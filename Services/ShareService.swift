//
//  ShareService.swift
//  InGermany
//

import SwiftUI
import UIKit

/// Сервис для предоставления возможности шаринга статей через системное окно iOS.
class ShareService {
    /// Делится выбранной статьей через системное меню iOS.
    /// - Parameters:
    ///   - article: Статья, которую нужно поделиться.
    ///   - language: Язык, на котором будет текст (по умолчанию русский).
    static func shareArticle(_ article: Article, language: String = "ru") {
        let title = article.localizedTitle(for: language)
        let content = article.localizedContent(for: language)
        
        let shareText = """
        \(title)
        
        \(content)
        
        Читайте в приложении InGermany!
        """
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}
