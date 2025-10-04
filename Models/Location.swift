//
//  Location.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import Foundation
import CoreLocation


/// Represents a geographic location with coordinates and name.
struct Location: Identifiable, Codable {
    /// Unique identifier of the location.
    let id: String
    /// Display name of the location.
    let name: String
    /// Latitude coordinate of the location.
    let latitude: Double
    /// Longitude coordinate of the location.
    let longitude: Double
    /// Computed CoreLocation coordinate (latitude and longitude) for use in MapKit.
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
