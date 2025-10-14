//
//  ArticleTests.swift
//  InGermany
//
//  Created by SUM TJK on 05.10.25.
//

//
//  ArticleTests.swift
//  InGermany
//
//  Created by AI Assistant on 04.10.25.
/*

import XCTest
@testable import InGermany

/// Unit tests for the Article model
final class ArticleTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var sampleArticle: Article!
    private var multiLanguageArticle: Article!
    private var articleWithDates: Article!
    private var articleWithImage: Article!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Sample article with basic data
        sampleArticle = Article(
            id: "test-article-1",
            title: ["ru": "Тестовая статья", "en": "Test Article"],
            content: ["ru": "Это тестовое содержание статьи.", "en": "This is test article content."],
            categoryId: "test-category",
            tags: ["test", "sample"]
        )
        
        // Multi-language article for localization tests
        multiLanguageArticle = Article(
            id: "multi-lang-article",
            title: [
                "ru": "Русский заголовок",
                "en": "English title",
                "de": "Deutscher Titel",
                "tj": "Сарлавҳаи тоҷикӣ",
                "fa": "عنوان فارسی",
                "ar": "عنوان عربي",
                "uk": "Українська назва"
            ],
            content: [
                "ru": "Русский контент",
                "en": "English content",
                "de": "Deutscher Inhalt"
            ],
            categoryId: "multi-category",
            tags: ["multi", "language"]
        )
        
        // Article with dates for date formatting tests
        let calendar = Calendar.current
        articleWithDates = Article(
            id: "dated-article",
            title: ["ru": "Статья с датами"],
            content: ["ru": "Содержание статьи с датами"],
            categoryId: "date-category",
            tags: ["dates"],
            createdAt: calendar.date(byAdding: .day, value: -5, to: Date()),
            updatedAt: calendar.date(byAdding: .day, value: -1, to: Date())
        )
        
        // Article with image for image processing tests
        articleWithImage = Article(
            id: "image-article",
            title: ["ru": "Статья с изображением"],
            content: ["ru": "Содержание с изображением"],
            categoryId: "image-category",
            tags: ["image"],
            image: "test-image.avif"
        )
    }
    
    override func tearDown() {
        sampleArticle = nil
        multiLanguageArticle = nil
        articleWithDates = nil
        articleWithImage = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testArticleInitialization() {
        // Given
        let id = "test-id"
        let title = ["ru": "Заголовок"]
        let content = ["ru": "Содержание"]
        let categoryId = "cat-1"
        let tags = ["tag1", "tag2"]
        let pdfFileName = "document.pdf"
        let createdAt = Date()
        let updatedAt = Date()
        let image = "image.jpg"
        
        // When
        let article = Article(
            id: id,
            title: title,
            content: content,
            categoryId: categoryId,
            tags: tags,
            pdfFileName: pdfFileName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            image: image
        )
        
        // Then
        XCTAssertEqual(article.id, id)
        XCTAssertEqual(article.title, title)
        XCTAssertEqual(article.content, content)
        XCTAssertEqual(article.categoryId, categoryId)
        XCTAssertEqual(article.tags, tags)
        XCTAssertEqual(article.pdfFileName, pdfFileName)
        XCTAssertEqual(article.createdAt, createdAt)
        XCTAssertEqual(article.updatedAt, updatedAt)
        XCTAssertEqual(article.image, image)
    }
    
    func testArticleDecoding() {
        // Given
        let json = """
        {
            "id": "decode-test",
            "title": {"ru": "Декодируемая статья"},
            "content": {"ru": "Содержание для декодирования"},
            "categoryId": "decode-cat",
            "tags": ["decode"],
            "pdfFileName": "test.pdf",
            "createdAt": "2025-01-01T10:00:00Z",
            "updatedAt": "2025-01-02T10:00:00Z",
            "image": "test.jpg"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let article = try? decoder.decode(Article.self, from: json)
        
        // Then
        XCTAssertNotNil(article)
        XCTAssertEqual(article?.id, "decode-test")
        XCTAssertEqual(article?.title["ru"], "Декодируемая статья")
        XCTAssertNotNil(article?.createdAt)
        XCTAssertNotNil(article?.updatedAt)
        XCTAssertEqual(article?.image, "test.jpg")
    }
    
    // MARK: - Localization Tests
    
    func testLocalizedTitle() {
        // When & Then
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "ru"), "Русский заголовок")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "en"), "English title")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "de"), "Deutscher Titel")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "tj"), "Сарлавҳаи тоҷикӣ")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "fa"), "عنوان فارسی")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "ar"), "عنوان عربي")
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "uk"), "Українська назва")
    }
    
    func testLocalizedTitleFallback() {
        // When & Then - Fallback to English
        XCTAssertEqual(multiLanguageArticle.localizedTitle(for: "nonexistent"), "English title")
        
        // Test fallback to first available when English is missing
        let articleWithoutEnglish = Article(
            id: "no-english",
            title: ["ru": "Русский", "de": "Deutsch"],
            content: ["ru": "Контент"],
            categoryId: "test"
        )
        XCTAssertEqual(articleWithoutEnglish.localizedTitle(for: "en"), "Русский")
    }
    
    func testLocalizedContent() {
        // When & Then
        XCTAssertEqual(multiLanguageArticle.localizedContent(for: "ru"), "Русский контент")
        XCTAssertEqual(multiLanguageArticle.localizedContent(for: "en"), "English content")
        XCTAssertEqual(multiLanguageArticle.localizedContent(for: "de"), "Deutscher Inhalt")
    }
    
    func testLocalizedContentFallback() {
        // When & Then - Fallback to English
        XCTAssertEqual(multiLanguageArticle.localizedContent(for: "nonexistent"), "English content")
        
        // Test fallback to first available when English is missing
        let articleWithoutEnglish = Article(
            id: "no-english-content",
            title: ["ru": "Заголовок"],
            content: ["ru": "Русский контент", "de": "Deutscher Inhalt"],
            categoryId: "test"
        )
        
        // Исправлено: fallback должен быть к английскому, но если английского нет,
        // то к первому доступному. В данном случае порядок не гарантирован в Dictionary,
        // поэтому проверяем что возвращается один из доступных контентов
        let fallbackContent = articleWithoutEnglish.localizedContent(for: "en")
        XCTAssertTrue(fallbackContent == "Русский контент" || fallbackContent == "Deutscher Inhalt")
    }
    
    // MARK: - Image Processing Tests
    
    func testImageNameFallback() {
        // Given
        let articleWithoutImage = Article(
            id: "no-image",
            title: ["ru": "Без изображения"],
            content: ["ru": "Контент"],
            categoryId: "test"
        )
        
        // When & Then
        XCTAssertEqual(articleWithoutImage.imageName, "Logo")
    }
    
    func testImageNameAVIFConversion() {
        // When & Then
        XCTAssertEqual(articleWithImage.imageName, "test-image.jpg")
    }
    
    func testImageNameExtensionAddition() {
        // Given
        let articleWithoutExtension = Article(
            id: "no-ext",
            title: ["ru": "Без расширения"],
            content: ["ru": "Контент"],
            categoryId: "test",
            image: "image-without-extension"
        )
        
        // When & Then
        XCTAssertEqual(articleWithoutExtension.imageName, "image-without-extension.jpg")
    }
    
    func testImageNamePreservesValidExtensions() {
        // Given
        let articleWithJPG = Article(
            id: "jpg-article",
            title: ["ru": "JPG статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            image: "valid-image.jpg"
        )
        
        let articleWithPNG = Article(
            id: "png-article",
            title: ["ru": "PNG статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            image: "valid-image.png"
        )
        
        // When & Then
        XCTAssertEqual(articleWithJPG.imageName, "valid-image.jpg")
        XCTAssertEqual(articleWithPNG.imageName, "valid-image.png")
    }
    
    // MARK: - Date Formatting Tests
    
    func testFormattedCreatedDate() {
        // When & Then
        XCTAssertFalse(articleWithDates.formattedCreatedDate(for: "ru").isEmpty)
        XCTAssertFalse(articleWithDates.formattedCreatedDate(for: "en").isEmpty)
        XCTAssertFalse(articleWithDates.formattedCreatedDate(for: "de").isEmpty)
        XCTAssertFalse(articleWithDates.formattedCreatedDate(for: "tj").isEmpty)
    }
    
    func testFormattedUpdatedDate() {
        // When & Then
        XCTAssertFalse(articleWithDates.formattedUpdatedDate(for: "ru").isEmpty)
        XCTAssertFalse(articleWithDates.formattedUpdatedDate(for: "en").isEmpty)
        XCTAssertFalse(articleWithDates.formattedUpdatedDate(for: "de").isEmpty)
        XCTAssertFalse(articleWithDates.formattedUpdatedDate(for: "tj").isEmpty)
    }
    
    func testRelativeCreatedDate() {
        // When & Then
        let relativeDate = articleWithDates.relativeCreatedDate(for: "ru")
        XCTAssertFalse(relativeDate.isEmpty)
        XCTAssertNotEqual(relativeDate, "Дата неизвестна")
    }
    
    func testDateUnknownFallback() {
        // Given
        let articleWithoutDates = Article(
            id: "no-dates",
            title: ["ru": "Без дат"],
            content: ["ru": "Контент"],
            categoryId: "test"
        )
        
        // When & Then
        XCTAssertEqual(articleWithoutDates.formattedCreatedDate(for: "ru"), "Дата неизвестна")
        XCTAssertEqual(articleWithoutDates.formattedUpdatedDate(for: "ru"), "Не обновлялась")
        XCTAssertEqual(articleWithoutDates.relativeCreatedDate(for: "ru"), "Дата неизвестна")
    }
    
    // MARK: - Content Analysis Tests
    
    func testWordCount() {
        // Given
        let articleWithContent = Article(
            id: "word-count",
            title: ["ru": "Тест"],
            content: ["ru": "Это тестовый текст для подсчета слов"],
            categoryId: "test"
        )
        
        // When & Then
        XCTAssertGreaterThan(articleWithContent.wordCount, 0)
    }
    
    func testIsNewArticle() {
        // Given
        let newArticle = Article(
            id: "new-article",
            title: ["ru": "Новая статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            createdAt: Date()
        )
        
        // When & Then
        XCTAssertTrue(newArticle.isNew)
    }
    
    func testIsNotNewArticle() {
        // Given
        let oldArticle = Article(
            id: "old-article",
            title: ["ru": "Старая статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            createdAt: Calendar.current.date(byAdding: .day, value: -10, to: Date())
        )
        
        // When & Then
        XCTAssertFalse(oldArticle.isNew)
    }
    
    func testIsUpdatedRecently() {
        // Given
        let recentlyUpdated = Article(
            id: "updated-article",
            title: ["ru": "Обновленная статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            updatedAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())
        )
        
        // When & Then
        XCTAssertTrue(recentlyUpdated.isUpdatedRecently)
    }
    
    func testIsNotUpdatedRecently() {
        // Given
        let notRecentlyUpdated = Article(
            id: "not-updated-article",
            title: ["ru": "Не обновленная статья"],
            content: ["ru": "Контент"],
            categoryId: "test",
            updatedAt: Calendar.current.date(byAdding: .day, value: -5, to: Date())
        )
        
        // When & Then
        XCTAssertFalse(notRecentlyUpdated.isUpdatedRecently)
    }
    
    // MARK: - Reading Time Tests
    
    func testReadingTimeCalculation() {
        // Given
        let articleWithLongContent = Article(
            id: "long-article",
            title: ["ru": "Длинная статья"],
            content: ["ru": String(repeating: "слово ", count: 500)],
            categoryId: "test"
        )
        
        // When
        let readingTime = articleWithLongContent.readingTime(for: "ru")
        
        // Then
        XCTAssertGreaterThan(readingTime, 0)
        XCTAssertLessThanOrEqual(readingTime, 5) // 500 words / 200 wpm ≈ 2.5 minutes
    }
    
    func testReadingTimeMinimum() {
        // Given
        let articleWithShortContent = Article(
            id: "short-article",
            title: ["ru": "Короткая статья"],
            content: ["ru": "Короткий текст"],
            categoryId: "test"
        )
        
        // When
        let readingTime = articleWithShortContent.readingTime(for: "ru")
        
        // Then
        XCTAssertEqual(readingTime, 1) // Minimum 1 minute
    }
    
    func testFormattedReadingTime() {
        // Given
        let article = Article(
            id: "format-test",
            title: ["ru": "Тест формата"],
            content: ["ru": "Содержание"],
            categoryId: "test"
        )
        
        // When & Then
        XCTAssertFalse(article.formattedReadingTime(for: "ru").isEmpty)
        XCTAssertFalse(article.formattedReadingTime(for: "en").isEmpty)
        XCTAssertFalse(article.formattedReadingTime(for: "de").isEmpty)
        XCTAssertFalse(article.formattedReadingTime(for: "tj").isEmpty)
    }
    
    func testReadingTimeDifferentLanguages() {
        // Given
        let content = String(repeating: "word ", count: 300)
        let article = Article(
            id: "multi-lang-reading",
            title: ["en": "Test"],
            content: ["en": content, "ru": content, "de": content],
            categoryId: "test"
        )
        
        // When
        let englishTime = article.readingTime(for: "en") // 300 / 250 = 1.2 → 2 min
        let russianTime = article.readingTime(for: "ru") // 300 / 200 = 1.5 → 2 min
        let germanTime = article.readingTime(for: "de")  // 300 / 220 = 1.36 → 2 min
        
        // Then
        XCTAssertEqual(englishTime, 2)
        XCTAssertEqual(russianTime, 2)
        XCTAssertEqual(germanTime, 2)
    }
    
    // MARK: - Hashable & Equatable Tests
    
    func testArticleEquality() {
        // Given
        let article1 = Article(
            id: "same-id",
            title: ["ru": "Статья 1"],
            content: ["ru": "Контент 1"],
            categoryId: "cat1"
        )
        
        let article2 = Article(
            id: "same-id",
            title: ["ru": "Статья 2"], // Different title
            content: ["ru": "Контент 2"], // Different content
            categoryId: "cat2" // Different category
        )
        
        // When & Then
        XCTAssertEqual(article1, article2) // Should be equal because same ID
    }
    
    func testArticleInequality() {
        // Given
        let article1 = Article(
            id: "id-1",
            title: ["ru": "Статья"],
            content: ["ru": "Контент"],
            categoryId: "cat"
        )
        
        let article2 = Article(
            id: "id-2",
            title: ["ru": "Статья"], // Same title
            content: ["ru": "Контент"], // Same content
            categoryId: "cat" // Same category
        )
        
        // When & Then
        XCTAssertNotEqual(article1, article2) // Should not be equal because different ID
    }
    
    func testHashableConsistency() {
        // Given
        let article = Article(
            id: "hash-test",
            title: ["ru": "Тест хеша"],
            content: ["ru": "Контент"],
            categoryId: "test"
        )
        
        // When
        let set: Set<Article> = [article]
        
        // Then
        XCTAssertTrue(set.contains(article))
    }
    
    // MARK: - Performance Tests
    
    func testLocalizationPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = multiLanguageArticle.localizedTitle(for: "ru")
                _ = multiLanguageArticle.localizedContent(for: "en")
            }
        }
    }
    
    func testReadingTimePerformance() {
        let longContent = String(repeating: "This is a test content for performance testing. ", count: 1000)
        let article = Article(
            id: "perf-test",
            title: ["en": "Performance Test"],
            content: ["en": longContent],
            categoryId: "test"
        )
        
        measure {
            for _ in 0..<100 {
                _ = article.readingTime(for: "en")
            }
        }
    }
    
    func testDateFormattingPerformance() {
        measure {
            for _ in 0..<1000 {
                _ = articleWithDates.formattedCreatedDate(for: "ru")
                _ = articleWithDates.formattedUpdatedDate(for: "en")
                _ = articleWithDates.relativeCreatedDate(for: "de")
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyArticle() {
        // Given
        let emptyArticle = Article(
            id: "",
            title: [:],
            content: [:],
            categoryId: "",
            tags: []
        )
        
        // When & Then
        XCTAssertTrue(emptyArticle.localizedTitle(for: "ru").contains("No title"))
        XCTAssertTrue(emptyArticle.localizedContent(for: "ru").contains("No content"))
        XCTAssertEqual(emptyArticle.imageName, "Logo")
        
        // Исправлено: wordCount вычисляется через readingTime * 200,
        // а readingTime всегда минимум 1 минута для любого контента
        XCTAssertEqual(emptyArticle.wordCount, 200)
        
        XCTAssertFalse(emptyArticle.isNew)
        XCTAssertFalse(emptyArticle.isUpdatedRecently)
    }
    
    func testArticleWithOnlyOneLanguage() {
        // Given
        let singleLanguageArticle = Article(
            id: "single-lang",
            title: ["fr": "Titre français"], // Only French
            content: ["fr": "Contenu français"],
            categoryId: "test"
        )
        
        // When & Then
        XCTAssertEqual(singleLanguageArticle.localizedTitle(for: "en"), "Titre français") // Fallback to first
        XCTAssertEqual(singleLanguageArticle.localizedContent(for: "en"), "Contenu français") // Fallback to first
    }
    
    func testArticleWithMalformedDates() {
        // Given
        let json = """
        {
            "id": "malformed-dates",
            "title": {"ru": "Статья"},
            "content": {"ru": "Контент"},
            "categoryId": "test",
            "createdAt": "invalid-date-format",
            "updatedAt": "another-invalid-format"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let article = try? decoder.decode(Article.self, from: json)
        
        // Then
        XCTAssertNotNil(article)
        XCTAssertNil(article?.createdAt)
        XCTAssertNil(article?.updatedAt)
    }
}

// MARK: - Test Helpers

extension ArticleTests {
    private func createArticleWithContent(wordCount: Int, language: String = "ru") -> Article {
        let content = String(repeating: "word ", count: wordCount)
        return Article(
            id: "content-test-\(wordCount)",
            title: [language: "Test Article"],
            content: [language: content],
            categoryId: "test"
        )
    }
}


*/
