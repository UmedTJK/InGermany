//
//  ReadingHistoryManager.swift
//  InGermany
//
//  Created by AI Assistant on 18.09.25.
//

import Foundation
import SwiftUI

// MARK: - Data Models

/// 📖 Модель записи истории чтения статьи.
/// Хранит идентификатор, дату прочтения и время чтения в секундах.
///
/// ## 🎯 Ответственность:
/// - Хранение метаданных о сессии чтения
/// - Предоставление вычисляемых свойств (длительность)
/// - Сериализация/десериализация для сохранения
struct ReadingHistoryEntry: Codable, Identifiable {
    // MARK: - Properties
    
    /// 🔑 Уникальный идентификатор записи (генерируется автоматически)
    let id: String
    
    /// 📄 Идентификатор статьи для связи с данными
    let articleId: String
    
    /// 📅 Дата и время начала чтения
    let readAt: Date
    
    /// ⏱️ Время чтения в секундах (фиксированное значение)
    let readingTimeSeconds: TimeInterval
    
    // MARK: - Computed Properties
    
    /// 🕒 Вычисляемая длительность чтения (только для завершенных сессий)
    var duration: TimeInterval? {
        // ⚠️ В текущей реализации всегда возвращает readingTimeSeconds
        // так как endTime не используется. Можно расширить в будущем.
        return readingTimeSeconds
    }
    
    // MARK: - Initialization
    
    /// 🏗️ Создаёт новую запись для указанной статьи с текущей датой
    /// - Parameters:
    ///   - articleId: Идентификатор статьи
    ///   - readingTimeSeconds: Время чтения в секундах
    ///
    /// ## 📝 Примечание:
    /// - ID генерируется автоматически через UUID
    /// - Время чтения фиксируется при создании
    /// - Дата устанавливается на момент создания
    init(articleId: String, readingTimeSeconds: TimeInterval) {
        self.id = UUID().uuidString
        self.articleId = articleId
        self.readAt = Date()
        self.readingTimeSeconds = readingTimeSeconds
    }
}

// MARK: - Main Manager

/// 📊 Менеджер для отслеживания истории чтения статей.
///
/// ## 🎯 Ответственность:
/// - Хранение и управление историей чтения
/// - Предоставление статистики и аналитики
/// - Сохранение/загрузка данных через DefaultsStore
/// - Обеспечение потокобезопасности через @MainActor
///
/// ## 🏗️ Архитектура:
/// - `@MainActor` - гарантия работы на главном потоке
/// - `ObservableObject` - интеграция с SwiftUI
/// - Singleton pattern - единый источник истины
@MainActor final class ReadingHistoryManager: ObservableObject {
    
    // MARK: - Singleton Instance
    
    /// 🌐 Глобально доступный экземпляр менеджера
    ///
    /// ## ⚠️ Важно:
    /// - Использует паттерн Singleton для согласованности данных
    /// - Все операции выполняются на главном потоке
    /// - Изменения автоматически публикуются через @Published
    static let shared = ReadingHistoryManager()
    
    // MARK: - Published Properties
    
    /// 📜 Список всех записей истории чтения (отсортирован по дате убывания)
    ///
    /// ## 🔄 Автоматические обновления:
    /// - SwiftUI views автоматически обновляются при изменениях
    /// - Сортировка сохраняется при добавлении новых записей
    @Published private(set) var history: [ReadingHistoryEntry] = []
    
    // MARK: - Private Properties
    
    /// 💾 Ключ для хранения данных в DefaultsStore
    private let storageKey = "readingHistory"
    
    /// 📊 Максимальное количество записей в истории (ограничение памяти)
    private let maxHistoryEntries = 100
    
    // MARK: - Initialization
    
    /// 🔒 Приватный инициализатор (паттерн Singleton)
    ///
    /// ## 📥 Автоматическая загрузка:
    /// - При создании менеджера данные загружаются из хранилища
    /// - История автоматически сортируется по дате
    private init() {
        loadHistory()
    }
    
    // MARK: - Data Persistence
    
    /// 📥 Загружает историю из DefaultsStore
    ///
    /// ## 🔄 Процесс загрузки:
    /// 1. Десериализация данных из DefaultsStore
    /// 2. Сортировка по убыванию даты (новые сначала)
    /// 3. Обновление @Published свойства
    private func loadHistory() {
        if let entries: [ReadingHistoryEntry] = DefaultsStore.load(storageKey, as: [ReadingHistoryEntry].self) {
            history = entries.sorted { $0.readAt > $1.readAt }
        }
    }
    
    /// 💾 Сохраняет историю в DefaultsStore
    ///
    /// ## 🛡️ Безопасность:
    /// - Автоматическая сериализация в JSON
    /// - Обработка ошибок внутри DefaultsStore
    /// - Сохранение происходит при каждом изменении
    private func saveHistory() {
        DefaultsStore.save(history, for: storageKey)
    }
    
    // MARK: - Public API
    
    /// ➕ Добавляет запись о прочтении статьи
    /// - Parameters:
    ///   - articleId: Идентификатор статьи
    ///   - readingTime: Время чтения в секундах
    ///
    /// ## 🔄 Логика добавления:
    /// 1. Удаление предыдущих записей для этой статьи (обновление)
    /// 2. Создание новой записи с текущим временем
    /// 3. Вставка в начало списка
    /// 4. Ограничение размера истории
    /// 5. Автоматическое сохранение
    func addReadingEntry(articleId: String, readingTime: TimeInterval) {
        // Удаляем предыдущие записи для этой статьи (обновление данных)
        history.removeAll { $0.articleId == articleId }
        
        // Создаем новую запись
        let entry = ReadingHistoryEntry(articleId: articleId, readingTimeSeconds: readingTime)
        history.insert(entry, at: 0)
        
        // Ограничиваем размер истории для оптимизации памяти
        if history.count > maxHistoryEntries {
            history = Array(history.prefix(maxHistoryEntries))
        }
        
        // Сохраняем изменения
        saveHistory()
    }
    
    /// 📚 Возвращает последние прочитанные статьи
    /// - Parameters:
    ///   - allArticles: Полный список статей для поиска
    ///   - limit: Максимальное количество (по умолчанию 5)
    /// - Returns: Список последних прочитанных статей
    ///
    /// ## 🔍 Процесс поиска:
    /// 1. Берем последние ID из истории
    /// 2. Ищем соответствующие статьи в общем списке
    /// 3. Возвращаем в порядке истории чтения
    func recentlyReadArticles(from allArticles: [Article], limit: Int = 5) -> [Article] {
        let recentIds = Array(history.prefix(limit).map { $0.articleId })
        return recentIds.compactMap { id in
            allArticles.first { $0.id == id }
        }
    }
    
    /// ✅ Проверяет, была ли статья прочитана
    /// - Parameter articleId: Идентификатор статьи
    /// - Returns: `true` если статья есть в истории
    func isRead(_ articleId: String) -> Bool {
        return history.contains { $0.articleId == articleId }
    }
    
    /// 📅 Возвращает дату последнего чтения статьи
    /// - Parameter articleId: Идентификатор статьи
    /// - Returns: Дата последнего чтения или `nil`
    func lastReadDate(for articleId: String) -> Date? {
        return history.first { $0.articleId == articleId }?.readAt
    }
    
    // MARK: - Statistics
    
    /// ⏱️ Общее время чтения всех статей (в минутах)
    var totalReadingTimeMinutes: Int {
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        return Int(totalSeconds / 60)
    }
    
    /// 📊 Количество уникальных прочитанных статей
    var totalArticlesRead: Int {
        return Set(history.map { $0.articleId }).count
    }
    
    /// 📈 Возвращает агрегированную статистику чтения
    /// - Returns: Структура ReadingStats с аналитикой
    func getStats() -> ReadingStats {
        return ReadingStats(from: history)
    }
    
    // MARK: - Data Management
    
    /// 🗑️ Очищает историю чтения
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    /// 🧪 Очищает историю для тестирования
    func clearForTesting() {
        history.removeAll()
        DefaultsStore.remove(storageKey)
    }
}

// MARK: - Real-time Reading Tracker

/// ⏱️ Трекер для измерения времени чтения статьи в реальном времени.
///
/// ## 🎯 Отличие от ReadingHistoryManager:
/// - **Этот класс**: отслеживает активные сессии в реальном времени
/// - **HistoryManager**: хранит завершенные сессии и статистику
///
/// ## 🏗️ Архитектура:
/// - `@MainActor` - гарантия работы на главном потоке
/// - `ObservableObject` - интеграция с SwiftUI
/// - Отдельный от HistoryManager для разделения ответственности
@MainActor class ReadingTracker: ObservableObject {
    
    // MARK: - Properties
    
    /// 🕐 Время начала текущей сессии чтения
    private var startTime: Date?
    
    /// 📄 Идентификатор текущей читаемой статьи
    private var articleId: String?
    
    // MARK: - Public API
    
    /// ▶️ Начинает отслеживание чтения статьи
    /// - Parameter articleId: Идентификатор статьи
    ///
    /// ## ⚠️ Важно:
    /// - Сбрасывает предыдущую сессию если она активна
    /// - Устанавливает текущее время как начало чтения
    func startReading(articleId: String) {
        self.articleId = articleId
        self.startTime = Date()
    }
    
    /// ⏹️ Завершает отслеживание и сохраняет результат
    ///
    /// ## 🔄 Логика завершения:
    /// 1. Проверяет наличие активной сессии
    /// 2. Вычисляет длительность чтения
    /// 3. Сохраняет в HistoryManager если > 10 секунд
    /// 4. Сбрасывает текущую сессию
    func finishReading() {
        guard let startTime = startTime,
              let articleId = articleId else { return }
        
        let readingTime = Date().timeIntervalSince(startTime)
        
        // Сохраняем только значимые сессии (> 10 секунд)
        if readingTime >= 10 {
            ReadingHistoryManager.shared.addReadingEntry(
                articleId: articleId,
                readingTime: readingTime
            )
        }
        
        // Сбрасываем текущую сессию
        self.startTime = nil
        self.articleId = nil
    }
    
    /// 🕒 Текущее время чтения с момента запуска
    var currentReadingTime: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Statistics Model

/// 📊 Структура статистики чтения.
///
/// ## 🎯 Ответственность:
/// - Агрегация данных для отображения в UI
/// - Вычисление производных метрик
/// - Предоставление готовой аналитики
struct ReadingStats {
    
    // MARK: - Properties
    
    /// 📚 Количество уникальных прочитанных статей
    let totalArticlesRead: Int
    
    /// ⏱️ Общее время чтения в минутах
    let totalReadingTimeMinutes: Int
    
    /// 📊 Среднее время чтения на статью в минутах
    let averageReadingTimeMinutes: Double
    
    /// 🔥 Количество дней подряд с чтением (streak)
    let readingStreak: Int
    
    // MARK: - Initialization
    
    /// 🏗️ Создаёт статистику из истории чтения
    /// - Parameter history: Список записей истории чтения
    ///
    /// ## 📈 Вычисляемые метрики:
    /// - Уникальные статьи: через Set для исключения дубликатов
    /// - Общее время: сумма всех длительностей
    /// - Среднее время: общее время / количество статей
    /// - Streak: алгоритм последовательных дней
    init(from history: [ReadingHistoryEntry]) {
        self.totalArticlesRead = Set(history.map { $0.articleId }).count
        
        let totalSeconds = history.reduce(0) { $0 + $1.readingTimeSeconds }
        self.totalReadingTimeMinutes = Int(totalSeconds / 60)
        
        self.averageReadingTimeMinutes = totalArticlesRead > 0
            ? Double(totalReadingTimeMinutes) / Double(totalArticlesRead)
            : 0
        
        self.readingStreak = ReadingStats.calculateStreak(from: history)
    }
    
    // MARK: - Private Methods
    
    /// 📅 Вычисляет streak (количество дней подряд с чтением, максимум 7)
    /// - Parameter history: Список записей истории
    /// - Returns: Количество последовательных дней с чтением
    ///
    /// ## 🔍 Алгоритм расчета:
    /// 1. Проверяет сегодняшний день
    /// 2. Идет назад по дням до 7 дней
    /// 3. Прерывается при первом пропущенном дне
    /// 4. Возвращает количество последовательных дней
    private static func calculateStreak(from history: [ReadingHistoryEntry]) -> Int {
        let calendar = Calendar.current
        let today = Date()
        var streak = 0
        var currentDate = today
        
        // Проверяем последние 7 дней
        for i in 0..<7 {
            let hasReadingThisDay = history.contains { entry in
                calendar.isDate(entry.readAt, inSameDayAs: currentDate)
            }
            
            if hasReadingThisDay {
                streak += 1
            } else if i > 0 {
                // Прерываем streak если нашли пропущенный день (кроме сегодня)
                break
            }
            
            // Переходим к предыдущему дню
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        return streak
    }
}
