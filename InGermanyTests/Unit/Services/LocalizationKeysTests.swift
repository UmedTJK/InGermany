//
//  LocalizationKeysTests.swift
//  InGermanyTests
//
//  Verifies that required localization keys are present in our custom LocalizationManager
//  (not in .lproj/Localizable.strings).
//

import XCTest
@testable import InGermany

final class LocalizationKeysTests: XCTestCase {

    /// Required keys that must resolve to a real, non-empty translation.
    private let requiredKeys: [String] = [
        "category_none"
    ]

    /// Languages we expect the app to support.
    /// NOTE: We validate via LocalizationManager, so absence of a `<lang>.lproj` is not an error.
    private let supportedLanguages: [String] = [
        "ru", "en", "de", "tj", "fa", "ar", "uk"
    ]

    func testRequiredLocalizationKeysExist() {
        let lm = LocalizationManager()
        lm.preload()

        for lang in supportedLanguages {
            for key in requiredKeys {
                let translation = lm.getTranslation(key: key, language: lang)

                XCTAssertFalse(
                    translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || translation == key,
                    "Отсутствует перевод для ключа `\(key)` в языке: \(lang)"
                )
            }
        }
    }
}
