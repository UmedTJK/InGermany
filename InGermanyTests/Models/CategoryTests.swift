//
//  CategoryTests.swift
//  InGermany
//
//  Created by AI Assistant on 04.10.25.
//

import XCTest
@testable import InGermany

/// Unit tests for the Category model
final class CategoryTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var sampleCategory: InGermany.Category!
    private var multiLanguageCategory: InGermany.Category!
    private var minimalCategory: InGermany.Category!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Sample category with basic data
        sampleCategory = InGermany.Category(
            id: "test-category-1",
            name: ["ru": "Тестовая категория", "en": "Test Category"],
            icon: "test.icon",
            colorHex: "#FF0000"
        )
        
        // Multi-language category for localization tests
        multiLanguageCategory = InGermany.Category(
            id: "multi-lang-category",
            name: [
                "ru": "Русское название",
                "en": "English name",
                "de": "Deutscher Name",
                "tj": "Номи тоҷикӣ",
                "fa": "نام فارسی",
                "ar": "اسم عربي",
                "uk": "Українська назва"
            ],
            icon: "globe",
            colorHex: "#4A90E2"
        )
        
        // Minimal category with required fields only
        minimalCategory = InGermany.Category(
            id: "minimal-category",
            name: ["ru": "Минимальная"],
            icon: "star",
            colorHex: "#000000"
        )
    }
    
    override func tearDown() {
        sampleCategory = nil
        multiLanguageCategory = nil
        minimalCategory = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testCategoryInitialization() {
        // Given
        let id = "test-id"
        let name = ["ru": "Категория", "en": "Category"]
        let icon = "banknote"
        let colorHex = "#27AE60"
        
        // When
        let category = InGermany.Category(
            id: id,
            name: name,
            icon: icon,
            colorHex: colorHex
        )
        
        // Then
        XCTAssertEqual(category.id, id)
        XCTAssertEqual(category.name, name)
        XCTAssertEqual(category.icon, icon)
        XCTAssertEqual(category.colorHex, colorHex)
    }
    
    func testCategoryDecoding() {
        // Given
        let json = """
        {
            "id": "decode-test",
            "name": {"ru": "Декодируемая категория", "en": "Decoded Category"},
            "icon": "star.fill",
            "colorHex": "#FF5733"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let category = try? decoder.decode(InGermany.Category.self, from: json)
        
        // Then
        XCTAssertNotNil(category)
        XCTAssertEqual(category?.id, "decode-test")
        XCTAssertEqual(category?.name["ru"], "Декодируемая категория")
        XCTAssertEqual(category?.name["en"], "Decoded Category")
        XCTAssertEqual(category?.icon, "star.fill")
        XCTAssertEqual(category?.colorHex, "#FF5733")
    }
    
    func testCategoryEncoding() {
        // Given
        let category = InGermany.Category(
            id: "encode-test",
            name: ["ru": "Тест кодирования"],
            icon: "circle",
            colorHex: "#123456"
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try? encoder.encode(category)
        let decoded = try? JSONDecoder().decode(InGermany.Category.self, from: data!)
        
        // Then
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.id, "encode-test")
        XCTAssertEqual(decoded?.name["ru"], "Тест кодирования")
        XCTAssertEqual(decoded?.icon, "circle")
        XCTAssertEqual(decoded?.colorHex, "#123456")
    }
    
    // MARK: - Localization Tests
    
    func testLocalizedName() {
        // When & Then
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "ru"), "Русское название")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "en"), "English name")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "de"), "Deutscher Name")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "tj"), "Номи тоҷикӣ")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "fa"), "نام فارسی")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "ar"), "اسم عربي")
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "uk"), "Українська назва")
    }
    
    func testLocalizedNameFallbackToEnglish() {
        // When & Then - Fallback to English for non-existent language
        XCTAssertEqual(multiLanguageCategory.localizedName(for: "nonexistent"), "English name")
    }
    
    func testLocalizedNameFallbackToFirstAvailable() {
        // Given - Category without English name
        let categoryWithoutEnglish = InGermany.Category(
            id: "no-english",
            name: ["ru": "Русское", "de": "Deutsch"],
            icon: "test",
            colorHex: "#000000"
        )
        
        // When & Then - Should fallback to first available name
        let fallbackName = categoryWithoutEnglish.localizedName(for: "en")
        XCTAssertTrue(fallbackName == "Русское" || fallbackName == "Deutsch")
    }
    
    func testLocalizedNameNoNameFallback() {
        // Given - Category with empty names
        let emptyCategory = InGermany.Category(
            id: "empty-names",
            name: [:],
            icon: "test",
            colorHex: "#000000"
        )
        
        // When & Then
        XCTAssertEqual(emptyCategory.localizedName(for: "ru"), "No name")
        XCTAssertEqual(emptyCategory.localizedName(for: "en"), "No name")
    }
    
    // MARK: - Identifiable Tests
    
    func testCategoryIdentifiable() {
        // Given
        let category1 = InGermany.Category(
            id: "id-1",
            name: ["ru": "Кат1"],
            icon: "icon1",
            colorHex: "#111111"
        )
        
        let category2 = InGermany.Category(
            id: "id-2",
            name: ["ru": "Кат2"],
            icon: "icon2",
            colorHex: "#222222"
        )
        
        // When
        let categories = [category1, category2]
        
        // Then - Should be identifiable by id
        XCTAssertEqual(categories[0].id, "id-1")
        XCTAssertEqual(categories[1].id, "id-2")
    }
    
    // MARK: - Sample Data Tests
    
    func testSampleCategories() {
        // When
        let sampleCategories = InGermany.Category.sampleCategories
        
        // Then
        XCTAssertEqual(sampleCategories.count, 2)
        
        let financeCategory = sampleCategories[0]
        XCTAssertEqual(financeCategory.id, "11111111-1111-1111-1111-aaaaaaaaaaaa")
        XCTAssertEqual(financeCategory.name["ru"], "Финансы")
        XCTAssertEqual(financeCategory.name["en"], "Finance")
        XCTAssertEqual(financeCategory.icon, "banknote")
        XCTAssertEqual(financeCategory.colorHex, "#4A90E2")
        
        let workCategory = sampleCategories[1]
        XCTAssertEqual(workCategory.id, "22222222-2222-2222-2222-bbbbbbbbbbbb")
        XCTAssertEqual(workCategory.name["ru"], "Работа")
        XCTAssertEqual(workCategory.name["en"], "Work")
        XCTAssertEqual(workCategory.icon, "briefcase")
        XCTAssertEqual(workCategory.colorHex, "#27AE60")
    }
    
    func testSampleCategoriesLocalization() {
        // Given
        let sampleCategories = InGermany.Category.sampleCategories
        let financeCategory = sampleCategories[0]
        
        // When & Then
        XCTAssertEqual(financeCategory.localizedName(for: "ru"), "Финансы")
        XCTAssertEqual(financeCategory.localizedName(for: "en"), "Finance")
        XCTAssertEqual(financeCategory.localizedName(for: "de"), "Finance") // Fallback to English
    }
    
    // MARK: - Manual Equality Tests (since Equatable is not implemented)
    
    func testCategoryManualEquality() {
        // Given
        let category1 = InGermany.Category(
            id: "same-id",
            name: ["ru": "Категория 1"],
            icon: "icon1",
            colorHex: "#111111"
        )
        
        let category2 = InGermany.Category(
            id: "same-id", // Same ID
            name: ["ru": "Категория 2"], // Different name
            icon: "icon2", // Different icon
            colorHex: "#222222" // Different color
        )
        
        // When & Then - Manual equality check by ID
        XCTAssertEqual(category1.id, category2.id)
        XCTAssertNotEqual(category1.name, category2.name)
        XCTAssertNotEqual(category1.icon, category2.icon)
        XCTAssertNotEqual(category1.colorHex, category2.colorHex)
    }
    
    func testCategoryManualInequality() {
        // Given
        let category1 = InGermany.Category(
            id: "id-1",
            name: ["ru": "Категория"],
            icon: "icon",
            colorHex: "#000000"
        )
        
        let category2 = InGermany.Category(
            id: "id-2", // Different ID
            name: ["ru": "Категория"], // Same name
            icon: "icon", // Same icon
            colorHex: "#000000" // Same color
        )
        
        // When & Then - Manual inequality check by ID
        XCTAssertNotEqual(category1.id, category2.id)
        XCTAssertEqual(category1.name, category2.name)
        XCTAssertEqual(category1.icon, category2.icon)
        XCTAssertEqual(category1.colorHex, category2.colorHex)
    }
    
    // MARK: - Performance Tests
    
    func testLocalizedNamePerformance() {
        measure {
            for _ in 0..<1000 {
                _ = multiLanguageCategory.localizedName(for: "ru")
                _ = multiLanguageCategory.localizedName(for: "en")
                _ = multiLanguageCategory.localizedName(for: "de")
            }
        }
    }
    
    func testCategoryDecodingPerformance() {
        let json = """
        {
            "id": "perf-test",
            "name": {"ru": "Тест производительности", "en": "Performance Test"},
            "icon": "gauge",
            "colorHex": "#FFAA00"
        }
        """.data(using: .utf8)!
        
        measure {
            for _ in 0..<1000 {
                let decoder = JSONDecoder()
                _ = try? decoder.decode(InGermany.Category.self, from: json)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyCategory() {
        // Given
        let emptyCategory = InGermany.Category(
            id: "",
            name: [:],
            icon: "",
            colorHex: ""
        )
        
        // When & Then
        XCTAssertEqual(emptyCategory.localizedName(for: "ru"), "No name")
        XCTAssertEqual(emptyCategory.localizedName(for: "en"), "No name")
        XCTAssertEqual(emptyCategory.icon, "")
        XCTAssertEqual(emptyCategory.colorHex, "")
    }
    
    func testCategoryWithOnlyOneLanguage() {
        // Given
        let singleLanguageCategory = InGermany.Category(
            id: "single-lang",
            name: ["fr": "Catégorie française"], // Only French
            icon: "flag",
            colorHex: "#FF0000"
        )
        
        // When & Then
        XCTAssertEqual(singleLanguageCategory.localizedName(for: "en"), "Catégorie française") // Fallback to first
        XCTAssertEqual(singleLanguageCategory.localizedName(for: "ru"), "Catégorie française") // Fallback to first
    }
    
    func testCategoryWithSpecialCharacters() {
        // Given
        let specialCategory = InGermany.Category(
            id: "special-chars",
            name: [
                "ru": "Категория с 🚀 эмодзи",
                "en": "Category with 🎉 emoji",
                "ar": "فئة مع 😊 الرموز التعبيرية"
            ],
            icon: "sparkles",
            colorHex: "#FF00FF"
        )
        
        // When & Then
        XCTAssertEqual(specialCategory.localizedName(for: "ru"), "Категория с 🚀 эмодзи")
        XCTAssertEqual(specialCategory.localizedName(for: "en"), "Category with 🎉 emoji")
        XCTAssertEqual(specialCategory.localizedName(for: "ar"), "فئة مع 😊 الرموز التعبيرية")
    }
    
    func testCategoryColorHexValidation() {
        // Given categories with various color hex formats
        let validHexCategory = InGermany.Category(
            id: "valid-hex",
            name: ["ru": "Валидный HEX"],
            icon: "paintbrush",
            colorHex: "#AABBCC"
        )
        
        let shortHexCategory = InGermany.Category(
            id: "short-hex",
            name: ["ru": "Короткий HEX"],
            icon: "paintbrush",
            colorHex: "#ABC"
        )
        
        let noHashCategory = InGermany.Category(
            id: "no-hash",
            name: ["ru": "Без решетки"],
            icon: "paintbrush",
            colorHex: "DDEEFF"
        )
        
        let invalidHexCategory = InGermany.Category(
            id: "invalid-hex",
            name: ["ru": "Невалидный HEX"],
            icon: "paintbrush",
            colorHex: "#GGHHII"
        )
        
        // When & Then - All should store the color hex as provided
        XCTAssertEqual(validHexCategory.colorHex, "#AABBCC")
        XCTAssertEqual(shortHexCategory.colorHex, "#ABC")
        XCTAssertEqual(noHashCategory.colorHex, "DDEEFF")
        XCTAssertEqual(invalidHexCategory.colorHex, "#GGHHII")
    }
    
    // MARK: - JSON Data Tests
    
    func testCategoriesJSONStructure() {
        // Given
        let jsonData = """
        [
          {
            "id": "11111111-1111-1111-1111-aaaaaaaaaaaa",
            "name": {
              "ru": "Финансы",
              "en": "Finance",
              "de": "Finanzen",
              "tj": "Молия"
            },
            "icon": "banknote",
            "colorHex": "#4A90E2"
          }
        ]
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let categories = try? decoder.decode([InGermany.Category].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(categories)
        XCTAssertEqual(categories?.count, 1)
        
        let category = categories?.first
        XCTAssertEqual(category?.id, "11111111-1111-1111-1111-aaaaaaaaaaaa")
        XCTAssertEqual(category?.name["ru"], "Финансы")
        XCTAssertEqual(category?.name["en"], "Finance")
        XCTAssertEqual(category?.name["de"], "Finanzen")
        XCTAssertEqual(category?.name["tj"], "Молия")
        XCTAssertEqual(category?.icon, "banknote")
        XCTAssertEqual(category?.colorHex, "#4A90E2")
    }
}

// MARK: - Test Helpers

extension CategoryTests {
    private func createCategoryWithNames(_ names: [String: String]) -> InGermany.Category {
        return InGermany.Category(
            id: "test-\(UUID().uuidString)",
            name: names,
            icon: "test",
            colorHex: "#000000"
        )
    }
}
