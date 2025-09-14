//
//  Theme.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//

import SwiftUI

struct Theme {
    // Базовые цвета
    static let primary = Color.blue
    static let secondary = Color.orange
    
    // Шрифты
    static let headline = Font.system(.headline, design: .rounded)
    static let body = Font.system(.body, design: .default)
}

final class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var background: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var text: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    func toggle() {
        isDarkMode.toggle()
    }
}
