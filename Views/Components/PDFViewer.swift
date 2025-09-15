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

    var body: some View {
        if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf"),
           let document = PDFDocument(url: url) {
            PDFKitView(document: document)
                .navigationTitle("PDF")
        } else {
            Text("PDF не найден.")
                .foregroundColor(.red)
                .padding()
        }
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
