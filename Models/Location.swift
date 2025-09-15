//
//  Location.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
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
