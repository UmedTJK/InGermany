//
//  SettingsManagingProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 11.01.26.
//
protocol SettingsManagingProtocol: AnyObject {
    var selectedLanguage: String { get set }
    var isDarkMode: Bool { get set }
    var relativeDates: Bool { get set }
    var selectedCardStyleIndex: Int { get set }

    func resetToDefaults()
}


