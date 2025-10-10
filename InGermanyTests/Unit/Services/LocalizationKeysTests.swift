//
//  LocalizationKeysTests.swift
//  InGermany
//
//  Created by SUM TJK on 10.10.25.
//
//
//  LocalizationKeysTests.swift
//  InGermanyTests
//

import XCTest

final class LocalizationKeysTests: XCTestCase {

    /// Список обязательных ключей для проверки
    private let requiredKeys = [
        "category_none"
    ]

    /// Список поддерживаемых языков в проекте
    private let supportedLanguages = [
        "ru", "en", "de", "tj", "fa", "ar", "uk"
    ]

    func testRequiredLocalizationKeysExist() {
        for lang in supportedLanguages {
            guard let path = Bundle.main.path(forResource: lang, ofType: "lproj"),
                  let bundle = Bundle(path: path)
            else {
                XCTFail("Не найден .lproj для языка: \(lang)")
                continue
            }

            for key in requiredKeys {
                let translation = NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
                XCTAssertFalse(
                    translation.isEmpty || translation == key,
                    "Отсутствует перевод для ключа `\(key)` в языке: \(lang)"
                )
            }
        }
    }
}

