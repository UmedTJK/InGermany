//
//  PDFViewer.swift
//  InGermany
//

import SwiftUI
import PDFKit

struct PDFViewer: View {
    let fileName: String
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    var body: some View {
        VStack {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
               let pdfDocument = PDFDocument(url: url) {
                PDFKitView(pdfDocument: pdfDocument)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Text(t("PDF не найден."))
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .navigationTitle(t("PDF"))
    }

    // 🔹 Шорткат для нового менеджера
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }

    // 🔹 Старый метод (оставлен для совместимости)
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "PDF": [
                "ru": "PDF", "en": "PDF", "de": "PDF",
                "tj": "PDF", "fa": "PDF", "ar": "PDF", "uk": "PDF"
            ],
            "PDF не найден.": [
                "ru": "PDF не найден.", "en": "PDF not found.", "de": "PDF nicht gefunden.",
                "tj": "PDF ёфт нашуд.", "fa": "PDF پیدا نشد.", "ar": "ملف PDF غير موجود.", "uk": "PDF не знайдено."
            ]
        ]
        return translations[key]?[language] ?? key
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}
