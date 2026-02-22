//
//  AppLogger.swift
//  InGermany
//
//  Created by SUM TJK on 22.02.26.
//

import OSLog

enum AppLogCategory: String {
    case network
    case dataService
    case metrics
}

struct AppLogger {
    static func logger(for category: AppLogCategory) -> Logger {
        Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "InGermany",
            category: category.rawValue
        )
    }
}
