//
//  PDFViewer.swift
//  InGermany
//

import SwiftUI
import PDFKit

/// Экран для отображения PDF-файлов с использованием PDFKit.
struct PDFViewer: View {
    /// Имя PDF-файла из ресурсов Bundle.
    let fileName: String
    /// Выбранный язык интерфейса для локализации текста.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    /// Основное содержимое: PDF-документ, если найден, либо сообщение об ошибке.
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

    /// Шорткат для получения перевода строки через LocalizationManager.
    private func t(_ key: String) -> String {
        LocalizationManager.shared.getTranslation(key: key, language: selectedLanguage)
    }

    /// Старый метод перевода, оставлен для совместимости.
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

/// Обёртка SwiftUI для отображения PDF-документов через PDFKit.
struct PDFKitView: UIViewRepresentable {
    /// PDF-документ, отображаемый в представлении.
    let pdfDocument: PDFDocument

    /// Создаёт и настраивает PDFView для отображения документа.
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    /// Обновляет PDFView (не используется в данном случае).
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
