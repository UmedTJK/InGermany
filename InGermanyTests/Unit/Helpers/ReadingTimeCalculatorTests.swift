//
//  ReadingTimeCalculatorTests.swift
//  InGermanyTests
//
//  Created by SUM TJK on 04.10.25.
//

import XCTest
@testable import InGermany

final class ReadingTimeCalculatorTests: XCTestCase {
    
    // MARK: - Test Data
    
    private let sampleRussianText = """
    Это пример текста на русском языке. Он содержит несколько предложений 
    для тестирования функции подсчета слов и расчета времени чтения.
    Каждое слово должно быть правильно подсчитано.
    """
    
    private let sampleEnglishText = """
    This is a sample text in English language. It contains several sentences
    for testing word counting function and reading time estimation.
    Every word should be counted correctly.
    """
    
    private let sampleGermanText = """
    Dies ist ein Beispieltext in deutscher Sprache. Er enthält mehrere Sätze
    zum Testen der Wortzählfunktion und der Lesezeitschätzung.
    Jedes Wort sollte korrekt gezählt werden.
    """
    
    private let sampleTajikText = """
    Ин матни намунавӣ ба забони тоҷикӣ мебошад. Он якчанд ҷумларо дар бар мегирад
    барои санҷиши функсияи ҳисобкунии калимаҳо ва баҳодиҳии вақти хондан.
    Ҳар калима бояд дуруст ҳисоб карда шавад.
    """
    
    private let emptyText = ""
    private let textWithOnlySpaces = "     \n   \t   "
    private let textWithSpecialCharacters = "Hello!!! @username #tag $100 50% test-word"
    private let textWithEmoji = "Hello 👋 World 🌍 Test ✅"
    private let veryLongText: String = {
        String(repeating: "word ", count: 10000)
    }()
    
    // MARK: - Reading Time Estimation Tests
    
    func testReadingTimeRussian() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: sampleRussianText, language: "ru")
        // Russian: 200 wpm, text has ~24 words → 24/200 = 0.12 → min 1 minute
        XCTAssertEqual(minutes, 1, "Russian text should take at least 1 minute")
    }
    
    func testReadingTimeEnglish() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: sampleEnglishText, language: "en")
        // English: 250 wpm, text has ~24 words → 24/250 = 0.096 → min 1 minute
        XCTAssertEqual(minutes, 1, "English text should take at least 1 minute")
    }
    
    func testReadingTimeGerman() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: sampleGermanText, language: "de")
        // German: 220 wpm, text has ~23 words → 23/220 = 0.1045 → min 1 minute
        XCTAssertEqual(minutes, 1, "German text should take at least 1 minute")
    }
    
    func testReadingTimeTajik() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: sampleTajikText, language: "tj")
        // Tajik: 180 wpm, text has ~25 words → 25/180 = 0.1389 → min 1 minute
        XCTAssertEqual(minutes, 1, "Tajik text should take at least 1 minute")
    }
    
    func testReadingTimeMinimumOneMinute() {
        let shortText = "Short text"
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: shortText, language: "ru")
        XCTAssertEqual(minutes, 1, "Even short text should take at least 1 minute")
    }
    
    func testReadingTimeLongText() {
        // 10000 words / 200 wpm = 50 minutes
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: veryLongText, language: "ru")
        XCTAssertEqual(minutes, 50, "Long text should calculate correct reading time")
    }
    
    func testReadingTimeFallbackLanguage() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: sampleRussianText, language: "unknown")
        // Should fallback to Russian (200 wpm)
        XCTAssertEqual(minutes, 1, "Unknown language should fallback to Russian")
    }
    
    func testReadingTimeEmptyText() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: emptyText, language: "ru")
        XCTAssertEqual(minutes, 1, "Empty text should return minimum 1 minute")
    }
    
    func testReadingTimeTextWithOnlySpaces() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: textWithOnlySpaces, language: "ru")
        XCTAssertEqual(minutes, 1, "Text with only spaces should return minimum 1 minute")
    }
    
    func testReadingTimeSpecialCharacters() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: textWithSpecialCharacters, language: "en")
        // Text has ~6 words → 6/250 = 0.024 → min 1 minute
        XCTAssertEqual(minutes, 1, "Text with special characters should calculate reading time")
    }
    
    func testReadingTimeWithEmoji() {
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: textWithEmoji, language: "en")
        // Text has ~3 words → 3/250 = 0.012 → min 1 minute
        XCTAssertEqual(minutes, 1, "Text with emoji should calculate reading time")
    }
    
    // MARK: - Word Count Verification Through Reading Time
    
    func testWordCountIndirectVerification() {
        // We can verify word count indirectly by testing reading time calculations
        // For Russian: 200 wpm
        
        // Test with known word counts
        let fiveWords = "one two three four five"
        let fiveWordsTime = ReadingTimeCalculator.estimateReadingTime(for: fiveWords, language: "ru")
        XCTAssertEqual(fiveWordsTime, 1, "5 words should take 1 minute (minimum)")
        
        let twoHundredWords = String(repeating: "word ", count: 200)
        let twoHundredWordsTime = ReadingTimeCalculator.estimateReadingTime(for: twoHundredWords, language: "ru")
        XCTAssertEqual(twoHundredWordsTime, 1, "200 words should take 1 minute (exactly 200 wpm)")
        
        let twoHundredOneWords = String(repeating: "word ", count: 201)
        let twoHundredOneWordsTime = ReadingTimeCalculator.estimateReadingTime(for: twoHundredOneWords, language: "ru")
        XCTAssertEqual(twoHundredOneWordsTime, 2, "201 words should take 2 minutes (ceil(201/200))")
    }
    
    // MARK: - Formatting Tests
    
    func testFormattingRussian() {
        let formatted = ReadingTimeCalculator.formatReadingTime(1, language: "ru")
        XCTAssertEqual(formatted, "1 мин чтения", "Russian singular formatting should be correct")
        
        let formattedPlural = ReadingTimeCalculator.formatReadingTime(5, language: "ru")
        XCTAssertEqual(formattedPlural, "5 мин чтения", "Russian plural formatting should be correct")
    }
    
    func testFormattingEnglish() {
        let formatted = ReadingTimeCalculator.formatReadingTime(1, language: "en")
        XCTAssertEqual(formatted, "1 min read", "English singular formatting should be correct")
        
        let formattedPlural = ReadingTimeCalculator.formatReadingTime(5, language: "en")
        XCTAssertEqual(formattedPlural, "5 min read", "English plural formatting should be correct")
    }
    
    func testFormattingGerman() {
        let formatted = ReadingTimeCalculator.formatReadingTime(1, language: "de")
        XCTAssertEqual(formatted, "1 Min. Lesezeit", "German singular formatting should be correct") // ← исправлено здесь
        
        let formattedPlural = ReadingTimeCalculator.formatReadingTime(5, language: "de")
        XCTAssertEqual(formattedPlural, "5 Min. Lesezeit", "German plural formatting should be correct")
    }
    
    func testFormattingTajik() {
        let formatted = ReadingTimeCalculator.formatReadingTime(1, language: "tj")
        XCTAssertEqual(formatted, "1 дақ хондан", "Tajik singular formatting should be correct")
        
        let formattedPlural = ReadingTimeCalculator.formatReadingTime(5, language: "tj")
        XCTAssertEqual(formattedPlural, "5 дақ хондан", "Tajik plural formatting should be correct")
    }
    
    func testFormattingFallbackLanguage() {
        let formatted = ReadingTimeCalculator.formatReadingTime(3, language: "unknown")
        XCTAssertEqual(formatted, "3 мин чтения", "Unknown language should fallback to Russian formatting")
    }
    
    func testFormattingEdgeCases() {
        // Test zero (though estimateReadingTime never returns 0)
        let zeroFormatted = ReadingTimeCalculator.formatReadingTime(0, language: "ru")
        XCTAssertEqual(zeroFormatted, "0 мин чтения", "Zero minutes should format correctly")
        
        // Test large number
        let largeFormatted = ReadingTimeCalculator.formatReadingTime(999, language: "en")
        XCTAssertEqual(largeFormatted, "999 min read", "Large numbers should format correctly")
    }
    
    // MARK: - Language Support Tests
    
    func testAllSupportedLanguages() {
        let supportedLanguages = ["ru", "en", "de", "tj"]
        let testText = "Sample text for testing"
        
        for language in supportedLanguages {
            let readingTime = ReadingTimeCalculator.estimateReadingTime(for: testText, language: language)
            XCTAssertEqual(readingTime, 1, "Language \(language) should support reading time calculation")
            
            let formatted = ReadingTimeCalculator.formatReadingTime(2, language: language)
            XCTAssertFalse(formatted.isEmpty, "Language \(language) should support formatting")
        }
    }
    
    func testUnsupportedLanguagesFallbackToRussian() {
        let unsupportedLanguages = ["fr", "es", "zh", "ja", "ko"]
        let testText = "Sample text"
        
        for language in unsupportedLanguages {
            let readingTime = ReadingTimeCalculator.estimateReadingTime(for: testText, language: language)
            // Should fallback to Russian (200 wpm)
            XCTAssertEqual(readingTime, 1, "Unsupported language \(language) should fallback to Russian for calculation")
            
            let formatted = ReadingTimeCalculator.formatReadingTime(2, language: language)
            XCTAssertEqual(formatted, "2 мин чтения", "Unsupported language \(language) should fallback to Russian for formatting")
        }
    }
    
    // MARK: - Edge Cases
    
    func testMixedLanguageContent() {
        let mixedText = "This is English. Это русский. Dies ist Deutsch. Ин тоҷикӣ."
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: mixedText, language: "ru")
        XCTAssertGreaterThan(minutes, 0, "Mixed language text should calculate reading time")
        XCTAssertEqual(minutes, 1, "Mixed language text should take at least 1 minute")
    }
    
    func testTextWithNewlinesAndTabs() {
        let textWithNewlines = "First line\nSecond line\tThird line\n\nFourth line"
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: textWithNewlines, language: "en")
        XCTAssertEqual(minutes, 1, "Text with newlines and tabs should calculate reading time")
    }
    
    func testVeryShortButMultipleWords() {
        let shortText = "a b c d e"
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: shortText, language: "en")
        XCTAssertEqual(minutes, 1, "Very short text with multiple words should take 1 minute")
    }
    
    func testSingleWord() {
        let singleWord = "Hello"
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: singleWord, language: "en")
        XCTAssertEqual(minutes, 1, "Single word should take 1 minute")
    }
    
    func testPunctuationOnly() {
        let punctuation = "!!! ??? ... ,,, ---"
        let minutes = ReadingTimeCalculator.estimateReadingTime(for: punctuation, language: "en")
        XCTAssertEqual(minutes, 1, "Punctuation only should take 1 minute")
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceWordCounting() {
        measure {
            _ = ReadingTimeCalculator.estimateReadingTime(for: veryLongText, language: "ru")
        }
    }
    
    func testPerformanceReadingTimeEstimation() {
        measure {
            _ = ReadingTimeCalculator.estimateReadingTime(for: veryLongText, language: "ru")
        }
    }
    
    func testPerformanceMultipleLanguages() {
        let texts = [sampleRussianText, sampleEnglishText, sampleGermanText, sampleTajikText]
        let languages = ["ru", "en", "de", "tj"]
        
        measure {
            for (text, language) in zip(texts, languages) {
                _ = ReadingTimeCalculator.estimateReadingTime(for: text, language: language)
            }
        }
    }
    
    func testPerformanceFormatting() {
        measure {
            for i in 1...1000 {
                _ = ReadingTimeCalculator.formatReadingTime(i % 10 + 1, language: "ru")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithArticleModel() {
        // This test verifies that the calculator works well with typical article content
        let typicalArticleContent = """
        В Германии существует несколько видов виз для разных целей пребывания. 
        Студенческая виза предназначена для обучения в университетах и языковых курсах.
        Рабочая виза требуется для трудоустройства в немецких компаниях.
        Туристическая виза позволяет находиться в стране до 90 дней.
        """
        
        let readingTime = ReadingTimeCalculator.estimateReadingTime(for: typicalArticleContent, language: "ru")
        XCTAssertGreaterThan(readingTime, 0, "Typical article content should have positive reading time")
        XCTAssertLessThanOrEqual(readingTime, 5, "Typical article content should have reasonable reading time")
    }
    
    func testConsistencyAcrossMultipleCalls() {
        let text = sampleRussianText
        let firstCall = ReadingTimeCalculator.estimateReadingTime(for: text, language: "ru")
        let secondCall = ReadingTimeCalculator.estimateReadingTime(for: text, language: "ru")
        let thirdCall = ReadingTimeCalculator.estimateReadingTime(for: text, language: "ru")
        
        XCTAssertEqual(firstCall, secondCall, "Multiple calls with same input should produce same result")
        XCTAssertEqual(secondCall, thirdCall, "Multiple calls with same input should produce same result")
        XCTAssertEqual(firstCall, thirdCall, "Multiple calls with same input should produce same result")
    }
    
    func testReadingTimeScalesWithTextLength() {
        let shortText = "Short text"
        let mediumText = String(repeating: "word ", count: 100)
        let longText = String(repeating: "word ", count: 400)
        
        let shortTime = ReadingTimeCalculator.estimateReadingTime(for: shortText, language: "ru")
        let mediumTime = ReadingTimeCalculator.estimateReadingTime(for: mediumText, language: "ru")
        let longTime = ReadingTimeCalculator.estimateReadingTime(for: longText, language: "ru")
        
        XCTAssertEqual(shortTime, 1, "Short text should take 1 minute")
        XCTAssertEqual(mediumTime, 1, "100 words should take 1 minute (100/200 = 0.5 → ceil to 1)")
        XCTAssertEqual(longTime, 2, "400 words should take 2 minutes (400/200 = 2)")
    }
    
    // MARK: - Real World Scenarios
    
    func testRealWorldArticleScenarios() {
        let scenarios = [
            ("Краткая заметка", "Небольшая статья на несколько предложений.", 1),
            ("Средняя статья", String(repeating: "Предложение. ", count: 50), 1),
            ("Длинная статья", String(repeating: "Развернутый абзац. ", count: 100), 1)
        ]
        
        for (description, content, expectedMinutes) in scenarios {
            let readingTime = ReadingTimeCalculator.estimateReadingTime(for: content, language: "ru")
            XCTAssertEqual(readingTime, expectedMinutes, "\(description) should take \(expectedMinutes) minute(s)")
        }
    }
    
    func testCrossLanguageConsistency() {
        // Same content in different languages should have similar reading times
        // accounting for different reading speeds
        let similarContent = [
            "ru": "Это тестовый текст для проверки времени чтения.",
            "en": "This is a test text for checking reading time.",
            "de": "Dies ist ein Testtext zur Überprüfung der Lesezeit.",
            "tj": "Ин матни санҷишӣ барои санҷиши вақти хондан мебошад."
        ]
        
        for (language, text) in similarContent {
            let readingTime = ReadingTimeCalculator.estimateReadingTime(for: text, language: language)
            XCTAssertEqual(readingTime, 1, "Similar content in \(language) should take 1 minute")
        }
    }
}
