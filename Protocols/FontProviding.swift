//
//  FontProviding.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
// Protocols/FontProviding.swift
// Protocols/FontProviding.swift
// Protocols/FontProviding.swift
import SwiftUI

/// Протокол для предоставления типографики в приложении
/// Отвечает за генерацию шрифтов с учетом текущего масштаба
@MainActor
protocol FontProviding {
    /// Основной шрифт для тела текста
    var bodyFont: Font { get }
    
    /// Шрифт для заголовков статей
    var titleFont: Font { get }
    
    /// Шрифт для крупных заголовков
    var headlineFont: Font { get }
    
    /// Шрифт для подписей и мелкого текста
    var captionFont: Font { get }
    
    /// Шрифт для подзаголовков
    var subheadlineFont: Font { get }
}
