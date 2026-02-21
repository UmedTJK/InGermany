//
//  ArticleRowViewModelTests.swift
//  InGermanyTests
//

import XCTest
import Combine
@testable import InGermany

@MainActor
final class ArticleRowViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var sut: ArticleRowViewModel!
    private var testArticle: Article!
    private var cancellables: Set<AnyCancellable> = []
    private var favoritesManager: FavoritesManager!
    private var ratingManager: RatingManager!
    private var localizationManager: LocalizationManager!
    private var readingStatsManager: ReadingStatsManager!
    private var dateFormattingService: DateFormattingServiceProtocol!
    private var textAnalysisService: TextAnalysisServiceProtocol!
    private var articleFormatter: ArticleFormatter!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        favoritesManager = FavoritesManager()
        ratingManager = RatingManager()
        localizationManager = LocalizationManager()
        readingStatsManager = ReadingStatsManager()
        dateFormattingService = DateFormattingService()
        textAnalysisService = TextAnalysisService()
        articleFormatter = ArticleFormatter(
            dateFormattingService: dateFormattingService,
            textAnalysisService: textAnalysisService
        )
        
        // Clean up before each test
        favoritesManager.clearForTesting()
        ratingManager.clearForTesting()
        
        // Create test article
        testArticle = Article(
            id: "test-article-1",
            title: [
                "ru": "Тестовая статья",
                "en": "Test Article",
                "de": "Test Artikel"
            ],
            content: [
                "ru": "Содержание тестовой статьи",
                "en": "Test article content",
                "de": "Test Artikel Inhalt"
            ],
            categoryId: "test-category",
            tags: ["test", "unit"],
            pdfFileName: "test.pdf",
            createdAt: Date(),
            updatedAt: Date(),
            image: "test_image.jpg"
        )
        
        // Initialize ViewModel with real managers
        sut = ArticleRowViewModel(
            article: testArticle,
            localizationManager: localizationManager,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager,
            categoriesRepo: CategoriesRepositoryImpl(dataService: DataService(networkService: NetworkService(), cacheManager: CacheService())),
            readingStatsManager: readingStatsManager,
            articleFormatter: articleFormatter
        )
    }
    
    override func tearDown() {
        // Clean up after each test
        favoritesManager.clearForTesting()
        ratingManager.clearForTesting()
        sut = nil
        testArticle = nil
        cancellables.removeAll()
        localizationManager = nil
        readingStatsManager = nil
        favoritesManager = nil
        ratingManager = nil
        articleFormatter = nil
        dateFormattingService = nil
        textAnalysisService = nil
        super.tearDown()
    }
    
    // MARK: - Helpers

    private func makeVM(article: Article) -> ArticleRowViewModel {
        ArticleRowViewModel(
            article: article,
            localizationManager: localizationManager,
            favoritesManager: favoritesManager,
            ratingManager: ratingManager,
            categoriesRepo: CategoriesRepositoryImpl(
                dataService: DataService(
                    networkService: NetworkService(),
                    cacheManager: CacheService()
                )
            ),
            readingStatsManager: readingStatsManager,
            articleFormatter: articleFormatter
        )
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        // Then - should initialize with correct values
        XCTAssertEqual(sut.article.id, "test-article-1")
        XCTAssertFalse(sut.isFavorite)
        XCTAssertEqual(sut.rating, 0)
        XCTAssertEqual(sut.imageName, "test_image.jpg")
    }
    
    func testConvenienceInitializer() {
        // When - use convenience init
        let convenienceVM = makeVM(article: testArticle)
        
        // Then - should initialize correctly
        XCTAssertEqual(convenienceVM.article.id, "test-article-1")
    }
    
    // MARK: - Favorite Management Tests
    
    func testToggleFavorite() {
        // Given
        XCTAssertFalse(sut.isFavorite)
        
        // When
        sut.toggleFavorite()
        
        // Then
        XCTAssertTrue(sut.isFavorite)
        XCTAssertTrue(favoritesManager.isFavorite("test-article-1"))
        
        // When - toggle back
        sut.toggleFavorite()
        
        // Then
        XCTAssertFalse(sut.isFavorite)
        XCTAssertFalse(favoritesManager.isFavorite("test-article-1"))
    }
    
    func testToggleFavoriteUpdatesPublishedProperty() {
        // Given
        let expectation = expectation(description: "isFavorite should update")
        var favoriteStates: [Bool] = []
        
        sut.$isFavorite
            .dropFirst()
            .sink { isFavorite in
                favoriteStates.append(isFavorite)
                if favoriteStates.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.toggleFavorite()
        sut.toggleFavorite()
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(favoriteStates, [true, false])
    }
    
    // MARK: - Rating Management Tests
    
    func testSetRating() {
        // Given - initial rating should be 0 after clearForTesting
        XCTAssertEqual(sut.rating, 0)
        
        // When - set rating to 4
        sut.setRating(4)
        
        // Then - should update rating
        XCTAssertEqual(sut.rating, 4)
        XCTAssertEqual(ratingManager.getRating(for: "test-article-1"), 4)
    }
    
    func testSetRatingMultipleTimes() {
        // When & Then
        sut.setRating(3)
        XCTAssertEqual(sut.rating, 3)
        
        sut.setRating(5)
        XCTAssertEqual(sut.rating, 5)
        
        sut.setRating(1)
        XCTAssertEqual(sut.rating, 1)
    }
    
    func testRatingRange() {
        // Test valid range
        sut.setRating(0)
        XCTAssertEqual(sut.rating, 0)
        
        sut.setRating(5)
        XCTAssertEqual(sut.rating, 5)
    }
    
    func testSetRatingUpdatesPublishedProperty() {
        // Given
        let expectation = expectation(description: "rating should update")
        var ratingValues: [Int] = []
        
        sut.$rating
            .dropFirst()
            .sink { rating in
                ratingValues.append(rating)
                if ratingValues.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.setRating(2)
        sut.setRating(4)
        
        // Then
        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(ratingValues, [2, 4])
    }
    
    // MARK: - Localization Tests
    
    func testTitleLocalization() {
        XCTAssertEqual(sut.title, "Тестовая статья")
    }
    
    func testSubtitleLocalization() {
        let subtitle = sut.subtitle
        XCTAssertFalse(subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        let expectedMinutes = articleFormatter.readingTime(testArticle, for: "ru")
        XCTAssertTrue(
            subtitle.contains("\(expectedMinutes)"),
            "Subtitle should contain reading time minutes (\(expectedMinutes)). Got: \(subtitle)"
        )
    }
    
    func testMetaInfoLocalization() {
        let metaInfo = sut.metaInfo
        XCTAssertFalse(metaInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        // Minimal, stable expectations: category fallback + tags are present.
        XCTAssertTrue(
            metaInfo.contains("Без категории"),
            "metaInfo should contain category fallback. metaInfo=\(metaInfo)"
        )
        XCTAssertTrue(
            metaInfo.contains("#test"),
            "metaInfo should contain tags. metaInfo=\(metaInfo)"
        )
    }
    
    // MARK: - Image Handling Tests
    
    func testImageNameWithNilImage() {
        // Given
        let articleWithoutImage = Article(
            id: "no-image-article",
            title: ["en": "No Image"],
            content: ["en": "Content"],
            categoryId: "test"
        )
        
        // When
        let vm = makeVM(article: articleWithoutImage)
        
        // Then
        XCTAssertNil(vm.imageName)
    }
    
    func testImageNameWithImage() {
        // Given
        let articleWithImage = Article(
            id: "with-image-article",
            title: ["en": "With Image"],
            content: ["en": "Content"],
            categoryId: "test",
            image: "photo.jpg"
        )
        
        // When
        let vm = makeVM(article: articleWithImage)
        
        // Then
        XCTAssertEqual(vm.imageName, "photo.jpg")
    }
    
    // MARK: - Independent Articles Tests
    
    func testIndependentArticlesDoNotShareFavorites() {
        // Given
        let article1 = Article(
            id: "article-1",
            title: ["en": "Article 1"],
            content: ["en": "Content 1"],
            categoryId: "test"
        )
        let article2 = Article(
            id: "article-2",
            title: ["en": "Article 2"],
            content: ["en": "Content 2"],
            categoryId: "test"
        )
        
        let vm1 = makeVM(article: article1)
        let vm2 = makeVM(article: article2)
        
        // When
        vm1.toggleFavorite()
        
        // Then
        XCTAssertTrue(vm1.isFavorite)
        XCTAssertFalse(vm2.isFavorite)
    }
    
    func testIndependentArticlesDoNotShareRatings() {
        // Given
        let article1 = Article(
            id: "article-1",
            title: ["en": "Article 1"],
            content: ["en": "Content 1"],
            categoryId: "test"
        )
        let article2 = Article(
            id: "article-2",
            title: ["en": "Article 2"],
            content: ["en": "Content 2"],
            categoryId: "test"
        )
        
        let vm1 = makeVM(article: article1)
        let vm2 = makeVM(article: article2)
        
        // When
        vm1.setRating(3)
        vm2.setRating(4)
        
        // Then
        XCTAssertEqual(vm1.rating, 3)
        XCTAssertEqual(vm2.rating, 4)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceToggleFavorite() {
        measure {
            sut.toggleFavorite()
        }
    }
    
    func testPerformanceSetRating() {
        measure {
            sut.setRating(3)
        }
    }
    
    // MARK: - Edge Cases
    
    func testArticleWithMinimalData() {
        // Given
        let minimalArticle = Article(
            id: "minimal",
            title: ["en": "Minimal"],
            content: ["en": "Content"],
            categoryId: "test"
        )
        
        // When
        let minimalVM = makeVM(article: minimalArticle)
        
        // Then
        XCTAssertEqual(minimalVM.title, "Minimal")
        XCTAssertFalse(minimalVM.isFavorite)
        XCTAssertEqual(minimalVM.rating, 0)
        XCTAssertNil(minimalVM.imageName)
    }
    
    func testArticleWithNoDates() {
        // Given
        let noDateArticle = Article(
            id: "no-date-article",
            title: ["en": "No Date"],
            content: ["en": "Content"],
            categoryId: "test",
            createdAt: nil,
            updatedAt: nil
        )
        
        // When
        let noDateVM = makeVM(article: noDateArticle)
        
        // Then
        let metaInfo = noDateVM.metaInfo
        XCTAssertFalse(metaInfo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

        // Minimal, stable expectation: should at least show category fallback and not crash when dates are nil.
        XCTAssertTrue(
            metaInfo.contains("Без категории"),
            "metaInfo should contain category fallback even when dates are nil. metaInfo=\(metaInfo)"
        )
    }
    
    func testArticleWithDifferentLanguages() {
        // Given
        let englishArticle = Article(
            id: "english-article",
            title: ["en": "English Only"],
            content: ["en": "English content"],
            categoryId: "test"
        )
        
        // When
        let englishVM = makeVM(article: englishArticle)
        
        // Then
        XCTAssertEqual(englishVM.title, "English Only")
    }
}
