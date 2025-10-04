//
//  StarRatingView.swift
//  InGermany
//
//  Created by SUM TJK on 26.09.25.
//

//
//  StarRatingView.swift
//  InGermany
//

import SwiftUI

/// Представление звёздного рейтинга, позволяющее пользователю выбрать оценку от 1 до 5.
struct StarRatingView: View {
    /// Текущая оценка, связанная с внешним состоянием.
    @Binding var rating: Int
    
    /// Основное представление: горизонтальный ряд звёзд, которые можно выбрать.
    var body: some View {
        HStack {
            ForEach(1..<6) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = star
                    }
            }
        }
    }
}
