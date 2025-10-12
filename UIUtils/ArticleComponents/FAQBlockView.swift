//
//  FAQBlockView.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

/// Accordion блок для FAQ (вопрос-ответ)
struct FAQBlockView: View {
    let question: String
    let answer: String
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(question)
                    .font(.headline)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .transition(.opacity.combined(with: .slide))
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}


