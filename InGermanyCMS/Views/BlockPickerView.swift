//
//  BlockPickerView.swift
//  InGermany
//
//  Created by SUM TJK on 13.10.25.
//

// Views/BlockPickerView.swift
import SwiftUI
import ArticleKit   // 👈 добавляем

public struct BlockPickerView: View {
    let onPick: (BlockType) -> Void

    public var body: some View {
        List {
            ForEach(BlockType.allCases, id: \.self) { type in
                Button {
                    onPick(type)
                } label: {
                    HStack {
                        Text(type.rawValue.capitalized)
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationTitle("Add Block")
    }
}
