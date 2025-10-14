//
//  PDFLibraryViewModel.swift
//  InGermany
//
//  Created by SUM TJK on 14.10.25.
//

import Foundation

public struct PDFItem: Identifiable, Hashable {
    public let id: UUID
    public let titleKey: String
    public let descriptionKey: String
    public let fileName: String

    public init(
        id: UUID = UUID(),
        titleKey: String,
        descriptionKey: String,
        fileName: String
    ) {
        self.id = id
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.fileName = fileName
    }
}

@MainActor
final class PDFLibraryViewModel: ObservableObject {
    private let localizationManager: LocalizationManager

    @Published private(set) var items: [PDFItem]

    init(localizationManager: LocalizationManager, items: [PDFItem]) {
        self.localizationManager = localizationManager
        self.items = items
    }

    // MARK: - Localization accessors
    func title(for item: PDFItem, language: String) -> String {
        localizationManager.getTranslation(key: item.titleKey, language: language)
    }

    func description(for item: PDFItem, language: String) -> String {
        localizationManager.getTranslation(key: item.descriptionKey, language: language)
    }
}
