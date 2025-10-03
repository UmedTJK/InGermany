//  ProgressBar.swift
//  InGermany

import SwiftUI

struct ProgressBar: View {
    var value: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 4)
                    .opacity(0.3)
                    .foregroundColor(.gray)

                Rectangle()
                    .frame(width: geometry.size.width * value, height: 4)
                    .foregroundColor(.blue)
                    .animation(.easeInOut(duration: 0.3), value: value)
            }
        }
        .frame(height: 4)
    }
}