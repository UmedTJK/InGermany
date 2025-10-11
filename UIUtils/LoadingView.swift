//
//  LoadingView.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// Полноэкранный оверлей с индикатором загрузки.
/// Используется для долгих операций (экспорт PDF, сетевые запросы).
struct LoadingView: View {
    var message: String?

    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                if let message = message {
                    Text(message)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .padding(.top, 4)
                }
            }
            .padding(20)
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
        }
        .transition(.opacity)
        .animation(.easeInOut, value: message)
    }
}
