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

struct StarRatingView: View {
    @Binding var rating: Int
    
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
