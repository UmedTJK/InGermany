//
//  SettingsViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 03.10.25.
//
//
//  SettingsViewModel.swift
//  InGermany
//

import SwiftUI

@MainActor
class SettingsViewModel: ObservableObject {
    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @Published var isHistoryCleared: Bool = false

    private let historyManager: ReadingHistoryManager

    init(historyManager: ReadingHistoryManager) {
        self.historyManager = historyManager
    }

    // Очистка истории чтения
    func clearHistory() {
        historyManager.clearHistory()
        isHistoryCleared = true
    }

    // Смена языка
    func changeLanguage(to lang: String) {
        selectedLanguage = lang
    }
    
    /// Возвращает агрегированную статистику чтения (`ReadingStats`), включая общее количество прочитанных статей, общее и среднее время чтения, а также streak.
    public func getStats() -> ReadingStats {
        return historyManager.getStats()
    }
}
