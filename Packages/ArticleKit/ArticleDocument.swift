//
//  ArticleDocument.swift
//  InGermany
//
//  Created by SUM TJK on 17.10.25.
//
// ArticleDocument.swift
import Foundation

public struct ArticleDocument: Codable {
    public let title: String
    public let sections: [ArticleSectionDTO]
    
    public init(title: String, sections: [ArticleSectionDTO]) {
        self.title = title
        self.sections = sections
    }
}
