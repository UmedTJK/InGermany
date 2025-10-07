//
//  Environment+ScreenSize.swift
//  InGermany
//
//  Created by SUM TJK on 07.10.25.
//
import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}

