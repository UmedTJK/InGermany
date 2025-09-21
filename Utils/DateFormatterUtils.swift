//
//  DateFormatterUtils.swift
//  InGermany
//
//  Created by SUM TJK on 21.09.25.
//
//
//  DateFormatterUtils.swift
//  InGermany
//
//  Created by Umed Sabzaev on 21.09.2025.
//

import Foundation

enum DateFormatterUtils {
    
    /// Форматирование даты публикации/обновления
    static func formattedDate(_ date: Date?, language: String = "en") -> String {
        guard let date else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language)
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Относительная дата (например: "2 дня назад")
    static func relativeDate(_ date: Date?, language: String = "en") -> String {
        guard let date else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: language)
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// Человеческое отображение времени чтения
    static func formattedReadingTime(minutes: Int, language: String = "en") -> String {
        switch language {
        case "ru":
            return "\(minutes) мин"
        case "de":
            return "\(minutes) Min."
        case "tj":
            return "\(minutes) дақ"
        default:
            return "\(minutes) min"
        }
    }
}

