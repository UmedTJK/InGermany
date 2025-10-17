//
//  FAQBlockView.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

/// Accordion блок для FAQ (вопрос-ответ)
public struct FAQBlockView: View {
    public let question: String
    public let answer: String
    @State private var isExpanded: Bool = false

    public init(question: String, answer: String) {
        self.question = question
        self.answer = answer
    }

    public var body: some View {
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
