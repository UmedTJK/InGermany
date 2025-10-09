//
//  LocalizationManagerProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 07.10.25.
//


import Foundation

/// Протокол для менеджера локализации
protocol LocalizationManagerProtocol {
    /// Текущий выбранный язык
    var selectedLanguage: String { get }
    
    /// Получить перевод для ключа и языка
    func getTranslation(key: String, language: String) -> String
    
    /// Упрощенный доступ с автоопределением текущего языка
    func t(_ key: String, language: String?) -> String
}
