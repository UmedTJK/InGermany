//
//  PreviewEnvironmentService.swift
//  InGermany
//
//  Created by SUM TJK on 25.10.25.
//

import SwiftUI

// Ключ для хранения состояния PreviewAppearance в Environment
private struct PreviewAppearanceKey: EnvironmentKey {
    static let defaultValue: PreviewAppearance = .auto
}

public extension EnvironmentValues {
    var previewAppearance: PreviewAppearance {
        get { self[PreviewAppearanceKey.self] }
        set { self[PreviewAppearanceKey.self] = newValue }
    }
}

public extension View {
    /// Устанавливает внешний вид предпросмотра (цветовая схема и фон) для потомков
    func previewAppearance(_ value: PreviewAppearance) -> some View {
        environment(\.previewAppearance, value)
    }
}
