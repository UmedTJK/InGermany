//
//  Animations.swift
//  InGermany
//
//  Created by SUM TJK on 14.09.25.
//
import SwiftUI

enum AppAnimations {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3)
    static let fade = Animation.easeInOut(duration: 0.3)
}

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

