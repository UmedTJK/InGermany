//
//  PreviewDevice.swift
//  InGermany
//
//  Created by SUM TJK on 23.10.25.
//

import SwiftUI

enum PreviewDevice: String, CaseIterable, Identifiable {
    case iPhoneSE = "iPhone SE (2/3 gen)"
    case iPhone14 = "iPhone 14"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPhone15 = "iPhone 15"
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone16 = "iPhone 16"
    case iPhone16Pro = "iPhone 16 Pro"
    case iPhone16ProMax = "iPhone 16 Pro Max"
    case iPhone17 = "iPhone 17"
    case iPhone17Pro = "iPhone 17 Pro"
    case iPhone17ProMax = "iPhone 17 Pro Max"
    case iPadMini = "iPad Mini (6 gen)"
    
    var id: String { rawValue }
    
    /// Размеры экранов в points (не пикселях)
    var size: CGSize {
        switch self {
        // iPhone SE 2/3 (4.7″)
        case .iPhoneSE:
            return CGSize(width: 375, height: 667)
        
        // iPhone 14 (6.1″)
        case .iPhone14:
            return CGSize(width: 390, height: 844)
        
        // iPhone 14 Pro Max (6.7″)
        case .iPhone14ProMax:
            return CGSize(width: 430, height: 932)
        
        // iPhone 15 & 15 Pro (6.1″)
        case .iPhone15, .iPhone15Pro:
            return CGSize(width: 393, height: 852)
        
        // iPhone 16 & 16 Pro (6.3″)
        case .iPhone16, .iPhone16Pro:
            return CGSize(width: 402, height: 874)
        
        // iPhone 16 Pro Max (6.9″)
        case .iPhone16ProMax:
            return CGSize(width: 430, height: 932)
        
        // iPhone 17 & 17 Pro (ожидаемо 6.3″)
        case .iPhone17, .iPhone17Pro:
            return CGSize(width: 402, height: 874)
        
        // iPhone 17 Pro Max (ожидаемо 6.9″, чуть выше чем у 16 Pro Max)
        case .iPhone17ProMax:
            return CGSize(width: 450, height: 974)
        
        // iPad Mini 6 (8.3″)
        case .iPadMini:
            return CGSize(width: 744, height: 1133)
        }
    }
    
    /// SF Symbol иконка для меню
    var icon: String {
        switch self {
        case .iPadMini:
            return "ipad"
        default:
            return "iphone"
        }
    }
}
