//
//  DateFormattingService.swift
//  InGermany
//
//  Created by SUM TJK on 08.10.25.
//
//
//  DateFormattingService.swift
//  InGermany
//

import Foundation

protocol DateFormattingServiceProtocol {
    func formattedDate(_ date: Date, for language: String) -> String
    func relativeDate(_ date: Date, for language: String) -> String
}

final class DateFormattingService: DateFormattingServiceProtocol {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    private let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()
    
    init() {}
    
    func formattedDate(_ date: Date, for language: String) -> String {
        dateFormatter.locale = locale(for: language)
        return dateFormatter.string(from: date)
    }
    
    func relativeDate(_ date: Date, for language: String) -> String {
        relativeFormatter.locale = locale(for: language)
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func locale(for language: String) -> Locale {
        switch language {
        case "en": return Locale(identifier: "en_US")
        case "de": return Locale(identifier: "de_DE")
        case "tj": return Locale(identifier: "ru_RU")
        default: return Locale(identifier: "ru_RU")
        }
    }
}
