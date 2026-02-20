//
//  HomeViewModelTests.swift
//  InGermanyTests
//

import XCTest
@testable import InGermany

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!

    override func setUp() async throws {
        try await super.setUp()
        
        let network = NetworkService()
        let cache = CacheService()
        let dataService = DataService(networkService: network, cacheManager: cache)
        
        sut = HomeViewModel(
            favoritesManager: FavoritesManager(),
            readingStatsManager: ReadingStatsManager(),
            categoriesRepository: CategoriesRepositoryImpl(dataService: dataService),
            articlesRepo: ArticlesRepositoryImpl(dataService: dataService),
            localizationManager: LocalizationManager()
        )
    }

    override func tearDown() async throws {
        sut = nil
        try await super.tearDown()
    }

    func testLoadData() async {
        await sut.loadData()
        XCTAssertFalse(sut.articles.isEmpty, "Articles should be loaded")
    }

    func testSelectRandomArticle() async {
        await sut.loadData()
        sut.selectRandomArticle()
        XCTAssertNotNil(sut.randomArticle, "Random article should be selected")
    }
}
