//
//  LoadingView.swift
//  InGermany
//
//  Created by Umed on 11.10.25.
//

import SwiftUI

/// Полноэкранный оверлей с индикатором загрузки.
/// Используется для долгих операций (экспорт PDF, сетевые запросы).
public struct LoadingView: View {
    public var message: String?

    /// Публичный инициализатор, чтобы можно было использовать `LoadingView()` в других модулях
    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
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
