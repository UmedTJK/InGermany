//
//  PreviewDevice.swift
//  InGermany
//
//  Created by SUM TJK on 23.10.25.
//
//

import SwiftUI

enum PreviewDevice: String, CaseIterable, Identifiable {
    case iPhoneSE = "iPhone SE"
    case iPhone14 = "iPhone 14"
    case iPhone14ProMax = "iPhone 14 Pro Max"
    case iPadMini = "iPad Mini"
    
    // новые модели
    case iPhone15 = "iPhone 15"
    case iPhone15Pro = "iPhone 15 Pro"
    case iPhone16 = "iPhone 16"
    case iPhone16Pro = "iPhone 16 Pro"
    case iPhone16ProMax = "iPhone 16 Pro Max"
    case iPhone17 = "iPhone 17"
    case iPhone17Pro = "iPhone 17 Pro"
    case iPhone17ProMax = "iPhone 17 Pro Max"
    
    var id: String { rawValue }
    
    var size: CGSize {
        switch self {
        case .iPhoneSE:
            return CGSize(width: 320, height: 568)
        case .iPhone14:
            return CGSize(width: 390, height: 844)
        case .iPhone14ProMax:
            return CGSize(width: 430, height: 932)
        case .iPadMini:
            return CGSize(width: 744, height: 1133)
            
        // iPhone 15
        case .iPhone15, .iPhone15Pro:
            return CGSize(width: 393, height: 852)
            
        // iPhone 16
        case .iPhone16, .iPhone16Pro:
            return CGSize(width: 402, height: 874)
        case .iPhone16ProMax:
            return CGSize(width: 430, height: 932)
            
        // iPhone 17
        case .iPhone17, .iPhone17Pro:
            return CGSize(width: 430, height: 932)
        case .iPhone17ProMax:
            return CGSize(width: 450, height: 952)
        }
    }
}


