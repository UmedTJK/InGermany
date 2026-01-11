import Foundation

public struct LocalizedText: Codable, Hashable, Sendable {
    public var values: [LocaleID: String]

    public init(values: [LocaleID: String] = [:]) {
        self.values = values
    }

    public func value(
        preferred locale: LocaleID,
        fallback: LocaleID? = nil
    ) -> String? {
        if let v = values[locale] { return v }
        if let fb = fallback, let v = values[fb] { return v }
        return values.values.first
    }
}

public extension LocalizedText {
    var isEffectivelyEmpty: Bool {
        values.values.allSatisfy {
            $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

