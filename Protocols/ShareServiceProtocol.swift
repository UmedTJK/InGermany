//
//  ShareServiceProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
// Protocols/ShareServiceProtocol.swift
import Foundation

/// Протокол для сервиса шаринга контента
@MainActor
protocol ShareServiceProtocol {
    /// Генерирует plain text для шаринга статьи
    func generatePlainText(article: Article, selectedLanguage: String) -> String
    
    /// Генерирует форматированный текст для шаринга
    func generateFormattedText(article: Article, selectedLanguage: String) -> String
    
    /// Показывает системное окно шаринга
    func showShareSheet(article: Article, selectedLanguage: String)
}
