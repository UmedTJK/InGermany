//
//  ArticleDocument.swift
//  InGermany
//
//  Created by SUM TJK on 17.10.25.
//
import Foundation

public struct ArticleDocumentModel: Codable {
    public let title: String
    public let sections: [ArticleSectionDTO]
    
    public init(title: String, sections: [ArticleSectionDTO]) {
        self.title = title
        self.sections = sections
    }
}
