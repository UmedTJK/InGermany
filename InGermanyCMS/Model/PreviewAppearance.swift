//
//  PreviewAppearance.swift
//  InGermany
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI

/// Состояние темы предпросмотра (для канваса устройств в редакторе)
public struct PreviewAppearance: Equatable, Codable {
    public var colorScheme: ColorScheme? // nil = Auto
    public var background: PreviewBackgroundStyle

    public init(colorScheme: ColorScheme? = nil,
                background: PreviewBackgroundStyle = .plain) {
        self.colorScheme = colorScheme
        self.background = background
    }

    // Удобные пресеты
    public static let auto  = PreviewAppearance(colorScheme: nil,     background: .plain)
    public static let light = PreviewAppearance(colorScheme: .light,  background: .plain)
    public static let dark  = PreviewAppearance(colorScheme: .dark,   background: .plain)

    // Человекочитаемое имя схемы
    public var schemeTitle: String {
        switch colorScheme {
        case .light: return "Light"
        case .dark:  return "Dark"
        default:     return "Auto"
        }
    }

    // MARK: - Codable
    private enum CodingKeys: String, CodingKey { case scheme, background }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let scheme = try c.decodeIfPresent(String.self, forKey: .scheme)
        switch scheme {
        case "light": colorScheme = .light
        case "dark":  colorScheme = .dark
        default:      colorScheme = nil
        }
        background = try c.decodeIfPresent(PreviewBackgroundStyle.self,
                                           forKey: .background) ?? .plain
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        let scheme: String? = {
            switch colorScheme {
            case .some(.light): return "light"
            case .some(.dark):  return "dark"
            default:            return nil
            }
        }()
        try c.encodeIfPresent(scheme, forKey: .scheme)
        try c.encode(background, forKey: .background)
    }
}
