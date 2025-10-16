// ./Models/ProtocolConformances.swift

import Foundation

// MARK: - Conformances to Protocols

extension FavoritesManager: FavoritesManagingProtocol {}

extension RatingManager: RatingManagerProtocol {}

// ⚠️ TextSizeManager пока без протокола.
// Если понадобится – можно создать Protocols/TextSizeManagingProtocol.swift
// и добавить extension здесь.

// ⚠️ LocalizationManager уже объявлен как LocalizationManagerProtocol
// в самом классе, поэтому здесь повторять extension не нужно.
