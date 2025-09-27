//
//  TextSizeManager.swift
//  InGermany
//
//  Created by Umed Sabzaev on 20.09.25.
//

import SwiftUI

class TextSizeManager: ObservableObject {
    static let shared = TextSizeManager()
    
    private let defaults = UserDefaults.standard
    private let fontSizeKey = "articleFontSize"
    private let isEnabledKey = "isCustomTextSizeEnabled"
    
    @Published var fontSize: CGFloat {
        didSet {
            defaults.set(Double(fontSize), forKey: fontSizeKey)
        }
    }
    
    @Published var isCustomTextSizeEnabled: Bool {
        didSet {
            defaults.set(isCustomTextSizeEnabled, forKey: isEnabledKey)
        }
    }
    
    init() {
        // Инициализируем из UserDefaults
        let storedSize = defaults.double(forKey: fontSizeKey)
        let storedIsEnabled = defaults.bool(forKey: isEnabledKey)
        
        self.fontSize = storedSize > 0 ? CGFloat(storedSize) : 16.0
        self.isCustomTextSizeEnabled = storedIsEnabled
    }
    
    // Предустановленные размеры
    let presetSizes: [CGFloat] = [14, 16, 18, 20, 22, 24]
    
    func resetToDefault() {
        fontSize = 16
        isCustomTextSizeEnabled = false
    }
    
    var currentFont: Font {
        .system(size: fontSize)
    }
}
