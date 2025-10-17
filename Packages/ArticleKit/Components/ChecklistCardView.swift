//
//  ChecklistCardView.swift
//  InGermany
//
//  Created by SUM TJK on 12.10.25.
//
import SwiftUI

/// Чеклист для статей (список шагов с возможностью отмечать выполненные)
import SwiftUI

/// Элемент чеклиста
public struct ChecklistItem {
    public var text: String
    public var isDone: Bool = false

    public init(text: String, isDone: Bool = false) {
        self.text = text
        self.isDone = isDone
    }
}

/// Чеклист для статей (список шагов с возможностью отмечать выполненные)
public struct ChecklistCardView: View {
    @State private var items: [ChecklistItem]

    public init(items: [ChecklistItem]) {
        _items = State(initialValue: items)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                HStack {
                    Button(action: {
                        items[index].isDone.toggle()
                    }) {
                        Image(systemName: items[index].isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(items[index].isDone ? .green : .gray)
                            .imageScale(.large)
                            .padding(.trailing, 4)
                    }
                    Text(items[index].text)
                        .strikethrough(items[index].isDone, color: .gray)
                        .foregroundColor(items[index].isDone ? .gray : .primary)
                        .animation(.easeInOut, value: items[index].isDone)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
