//
//  RatingManagerProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 07.10.25.
//

protocol RatingManagerProtocol {
    func getRating(for articleId: String) -> Int
    func setRating(_ rating: Int, for articleId: String)
    func clearForTesting() // обязательно добавить
}
