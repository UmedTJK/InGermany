//
//  PreviewBackgroundStyle.swift
//  InGermany
//
//  Created by SUM TJK on 23.10.25.
//

import SwiftUI

/// Опции для выбора фона в предпросмотре устройства
enum PreviewBackgroundStyle: String, CaseIterable, Identifiable {
    case light
    case dark
    case auto
    
    var id: String { rawValue }
}
