//
//  ExportToPDF.swift
//  InGermany
//
//  Created by SUM TJK on 18.09.2025.
//

import Foundation
import PDFKit
import SwiftUI

struct ExportToPDF {
    
    static func export(title: String, content: String, fileName: String) {
        let pdfMetaData = [
            kCGPDFContextCreator: "InGermany App",
            kCGPDFContextAuthor: "Umed Sabzaev",
            kCGPDFContextTitle: title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2  // A4 size width
        let pageHeight = 841.8 // A4 size height
        let margin: CGFloat = 20

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let bodyFont = UIFont.systemFont(ofSize: 16)

            let titleAttributes: [NSAttributedString.Key: Any] = [.font: titleFont]
            let bodyAttributes: [NSAttributedString.Key: Any] = [.font: bodyFont]

            var yOffset: CGFloat = margin

            let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
            attributedTitle.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: 100))
            yOffset += 40

            let attributedBody = NSAttributedString(string: content, attributes: bodyAttributes)
            attributedBody.draw(in: CGRect(x: margin, y: yOffset, width: pageWidth - 2 * margin, height: pageHeight - yOffset - margin))
        }

        // Save to Documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfURL = documentsURL.appendingPathComponent("\(fileName).pdf")

        do {
            try data.write(to: pdfURL)
            print("✅ PDF успешно сохранён в: \(pdfURL.path)")
        } catch {
            print("❌ Ошибка при сохранении PDF: \(error.localizedDescription)")
        }
    }
}
