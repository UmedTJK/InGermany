//
//  ShareServiceProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
// Protocols/ShareServiceProtocol.swift
import Foundation

/// Протокол для сервиса шаринга контента
protocol ShareServiceProtocol {
    /// Генерирует plain text для шаринга статьи
    func generatePlainText(article: Article, selectedLanguage: String) -> String
    
    /// Генерирует форматированный текст для шаринга
    func generateFormattedText(article: Article, selectedLanguage: String) -> String
    
    /// Возвращает элементы для системного шаринга. UI-презентация должна происходить в UI-слое (SwiftUI .sheet).
    func makeShareItems(article: Article, selectedLanguage: String) -> [Any]
}
