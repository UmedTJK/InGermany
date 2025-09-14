//
//  ShareService.swift
//  InGermany
//

//
//  ShareService.swift
//  InGermany
//

import SwiftUI
import UIKit

class ShareService {
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
