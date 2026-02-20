//
//  NetworkServiceProtocol.swift
//  InGermany
//
//  Created by SUM TJK on 20.02.26.
//
import Foundation

protocol NetworkServiceProtocol {
    func loadJSON<T: Decodable>(from file: String) async throws -> T
    func loadJSONWithSource<T: Decodable>(from file: String) async throws -> (T, NetworkService.DataSource)
    func clearCache()
}
