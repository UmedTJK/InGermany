//
//  Category.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
// Category.swift - ЗАМЕНИТЕ ВЕСЬ ФАЙЛ
//
//  Category.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    let id: String
    let name: [String: String]
    let icon: String

    func localizedName(for lang: String) -> String {
        return name[lang] ?? name["de"] ?? name["en"] ?? name["ru"] ?? "Без названия"
    }

    // Цвет для иконки (по id категории)
    var color: Color {
        switch id {
        case "11111111-1111-1111-1111-aaaaaaaaaaaa": return .green   // Финансы
        case "22222222-2222-2222-2222-bbbbbbbbbbbb": return .blue    // Работа
        case "33333333-3333-3333-3333-cccccccccccc": return .purple  // Учёба
        case "44444444-4444-4444-4444-dddddddddddd": return .orange  // Бюрократия
        case "55555555-5555-5555-5555-eeeeeeeeeeee": return .pink    // Жизнь
        default: return .gray
        }
    }
}
