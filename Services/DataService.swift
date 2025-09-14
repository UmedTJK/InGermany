//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
// DataService.swift - ЗАМЕНИТЕ ВЕСЬ ФАЙЛ
//
//  DataService.swift
//  InGermany
//
//  Created by SUM TJK on 13.09.25.
//
import Foundation

final class DataService {
    static let shared = DataService()
    
    private init() {}
    
    /// Универсальная загрузка любого Decodable файла из бандла
    private func load<T: Decodable>(_ filename: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("⚠️ Файл \(filename) не найден в бандле")
            return [] as! T
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            print("⚠️ Не удалось загрузить \(filename) из бандла: \(error)")
            return [] as! T
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("⚠️ Не удалось декодировать \(filename): \(error)")
            return [] as! T
        }
    }
    
    /// Загрузка списка статей
    func loadArticles() -> [Article] {
        return load("articles.json")
    }
    
    /// Загрузка списка категорий
    func loadCategories() -> [Category] {
        return load("categories.json")
    }
}
