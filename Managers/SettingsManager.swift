//
//  SettingsManager.swift
//  InGermany
//
//  Created by SUM TJK on 11.01.26.
//

import SwiftUI

final class SettingsManager: SettingsManagingProtocol {

    @AppStorage("selectedLanguage") var selectedLanguage: String = "ru"
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @AppStorage("relativeDates") var relativeDates: Bool = true
    @AppStorage("selectedCardStyleIndex") var selectedCardStyleIndex: Int = 0

    func resetToDefaults() {
        selectedLanguage = "ru"
        isDarkMode = false
        relativeDates = true
        selectedCardStyleIndex = 0
    }
}
