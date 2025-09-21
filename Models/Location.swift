//
//  Location.swift
//  InGermany
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Sample Data для Preview
extension Location {
    static let example = Location(
        id: UUID().uuidString,
        name: "Berlin",
        latitude: 52.5200,
        longitude: 13.4050
    )
    
    static let sampleLocations: [Location] = [
        example,
        Location(
            id: UUID().uuidString,
            name: "Munich",
            latitude: 48.1351,
            longitude: 11.5820
        )
    ]
}
