//
//  PDFViewer.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    let fileName: String
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    
    var body: some View {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
           let document = PDFDocument(url: url) {
            PDFKitView(document: document)
                .navigationTitle(getTranslation(key: "PDF", language: selectedLanguage))
        } else {
            Text(getTranslation(key: "PDF не найден.", language: selectedLanguage))
                .foregroundColor(.red)
                .padding()
        }
    }
    
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "PDF": [
                "ru": "PDF",
                "en": "PDF",
                "de": "PDF",
                "tj": "PDF",
                "fa": "PDF",
                "ar": "PDF",
                "uk": "PDF"
            ],
            "PDF не найден.": [
                "ru": "PDF не найден.",
                "en": "PDF not found.",
                "de": "PDF nicht gefunden.",
                "tj": "PDF ёфт нашуд.",
                "fa": "فایل PDF یافت نشد.",
                "ar": "لم يتم العثور على ملف PDF.",
                "uk": "PDF не знайдено."
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

struct PDFKitView: UIViewRepresentable {
    let document: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
