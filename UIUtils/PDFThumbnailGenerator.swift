//
//  PDFThumbnailGenerator.swift
//  InGermany
//
//  Created by SUM TJK on 15.10.25.
//

import SwiftUI
import PDFKit

enum PDFThumbnail {
    case thumbnail(Image)
    case fallback(Image)
}

enum PDFThumbnailGenerator {
    static func generate(for fileName: String, size: CGSize = CGSize(width: 80, height: 100)) -> PDFThumbnail {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
              let pdfDoc = PDFDocument(url: url),
              let page = pdfDoc.page(at: 0) else {
            return .fallback(Image(systemName: "doc.richtext"))
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(CGRect(origin: .zero, size: size))
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }

        return .thumbnail(Image(uiImage: img))
    }
}
