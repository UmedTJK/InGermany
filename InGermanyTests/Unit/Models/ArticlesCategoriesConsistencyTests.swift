//
//  ArticlesCategoriesConsistencyTests.swift
//  InGermanyTests
//

/*
import XCTest
@testable import InGermany

final class ArticlesCategoriesConsistencyTests: XCTestCase {

    func testAllArticlesHaveValidCategory() throws {
        let testBundle = Bundle(for: type(of: self))

        guard
            let articlesURL = testBundle.url(forResource: "articles", withExtension: "json"),
            let categoriesURL = testBundle.url(forResource: "categories", withExtension: "json")
        else {
            XCTFail("Не удалось найти файлы articles.json или categories.json в тестовом бандле")
            return
        }

        let articlesData = try Data(contentsOf: articlesURL)
        let categoriesData = try Data(contentsOf: categoriesURL)

        let decoder = JSONDecoder()

        let articles = try decoder.decode([Article].self, from: articlesData)
        let categories = try decoder.decode([Category].self, from: categoriesData)

        let categoryIds = Set(categories.map { $0.id })

        for article in articles {
            let ruTitle: String = (article.title["ru"] as String?) ?? "Без названия"
            XCTAssertTrue(
                categoryIds.contains(article.categoryId),
                "Статья \(article.id) (\(ruTitle)) имеет невалидный categoryId: \(article.categoryId)"
            )
        }
    }
}

*/
