//
//  LocationTests.swift
//  InGermany
//
//  Created by SUM TJK on 05.10.25.
//
//
//  LocationTests.swift
//  InGermany
//
//  Created by AI Assistant on 05.10.25.
//

import XCTest
import CoreLocation
@testable import InGermany

/// Unit tests for the Location model
final class LocationTests: XCTestCase {
    
    // MARK: - Test Data
    
    private var sampleLocation: InGermany.Location!
    private var embassyLocation: InGermany.Location!
    private var buergeramtLocation: InGermany.Location!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        
        // Sample location with basic data
        sampleLocation = InGermany.Location(
            id: "test-location-1",
            name: "Тестовая локация",
            latitude: 52.5200,
            longitude: 13.4050
        )
        
        // Embassy location based on real data
        embassyLocation = InGermany.Location(
            id: "1",
            name: "Посольство Германии в Душанбе",
            latitude: 38.5731,
            longitude: 68.7791
        )
        
        // Bürgeramt location based on real data
        buergeramtLocation = InGermany.Location(
            id: "3",
            name: "Bürgeramt Berlin",
            latitude: 52.5200,
            longitude: 13.4050
        )
    }
    
    override func tearDown() {
        sampleLocation = nil
        embassyLocation = nil
        buergeramtLocation = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testLocationInitialization() {
        // Given
        let id = "test-id"
        let name = "Test Location"
        let latitude = 40.7128
        let longitude = -74.0060
        
        // When
        let location = InGermany.Location(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude
        )
        
        // Then
        XCTAssertEqual(location.id, id)
        XCTAssertEqual(location.name, name)
        XCTAssertEqual(location.latitude, latitude)
        XCTAssertEqual(location.longitude, longitude)
    }
    
    func testLocationDecoding() {
        // Given
        let json = """
        {
            "id": "decode-test",
            "name": "Декодируемая локация",
            "latitude": 48.8566,
            "longitude": 2.3522
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let location = try? decoder.decode(InGermany.Location.self, from: json)
        
        // Then
        XCTAssertNotNil(location)
        XCTAssertEqual(location?.id, "decode-test")
        XCTAssertEqual(location?.name, "Декодируемая локация")
        XCTAssertEqual(location?.latitude, 48.8566)
        XCTAssertEqual(location?.longitude, 2.3522)
    }
    
    func testLocationEncoding() {
        // Given
        let location = InGermany.Location(
            id: "encode-test",
            name: "Тест кодирования",
            latitude: 35.6895,
            longitude: 139.6917
        )
        
        // When
        let encoder = JSONEncoder()
        let data = try? encoder.encode(location)
        let decoded = try? JSONDecoder().decode(InGermany.Location.self, from: data!)
        
        // Then
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.id, "encode-test")
        XCTAssertEqual(decoded?.name, "Тест кодирования")
        XCTAssertEqual(decoded?.latitude, 35.6895)
        XCTAssertEqual(decoded?.longitude, 139.6917)
    }
    
    // MARK: - Coordinate Tests
    
    func testCoordinateComputation() {
        // Given
        let location = InGermany.Location(
            id: "coordinate-test",
            name: "Coordinate Test",
            latitude: 51.5074,
            longitude: -0.1278
        )
        
        // When
        let coordinate = location.coordinate
        
        // Then
        XCTAssertEqual(coordinate.latitude, 51.5074)
        XCTAssertEqual(coordinate.longitude, -0.1278)
        // Тип coordinate гарантированно CLLocationCoordinate2D, проверка не нужна
    }
    
    func testCoordinateAccuracy() {
        // Given
        let preciseLocation = InGermany.Location(
            id: "precise",
            name: "Precise Location",
            latitude: 52.518611,
            longitude: 13.408333
        )
        
        // When
        let coordinate = preciseLocation.coordinate
        
        // Then
        XCTAssertEqual(coordinate.latitude, 52.518611, accuracy: 0.000001)
        XCTAssertEqual(coordinate.longitude, 13.408333, accuracy: 0.000001)
    }
    
    // MARK: - Identifiable Tests
    
    func testLocationIdentifiable() {
        // Given
        let location1 = InGermany.Location(
            id: "location-1",
            name: "Location 1",
            latitude: 1.0,
            longitude: 1.0
        )
        
        let location2 = InGermany.Location(
            id: "location-2",
            name: "Location 2",
            latitude: 2.0,
            longitude: 2.0
        )
        
        // When
        let locations = [location1, location2]
        
        // Then - Should be identifiable by id
        XCTAssertEqual(locations[0].id, "location-1")
        XCTAssertEqual(locations[1].id, "location-2")
    }
    
    // MARK: - Real Data Tests
    
    func testEmbassyLocationData() {
        // When & Then
        XCTAssertEqual(embassyLocation.id, "1")
        XCTAssertEqual(embassyLocation.name, "Посольство Германии в Душанбе")
        XCTAssertEqual(embassyLocation.latitude, 38.5731)
        XCTAssertEqual(embassyLocation.longitude, 68.7791)
        
        let coordinate = embassyLocation.coordinate
        XCTAssertEqual(coordinate.latitude, 38.5731)
        XCTAssertEqual(coordinate.longitude, 68.7791)
    }
    
    func testBuergeramtLocationData() {
        // When & Then
        XCTAssertEqual(buergeramtLocation.id, "3")
        XCTAssertEqual(buergeramtLocation.name, "Bürgeramt Berlin")
        XCTAssertEqual(buergeramtLocation.latitude, 52.5200)
        XCTAssertEqual(buergeramtLocation.longitude, 13.4050)
        
        let coordinate = buergeramtLocation.coordinate
        XCTAssertEqual(coordinate.latitude, 52.5200)
        XCTAssertEqual(coordinate.longitude, 13.4050)
    }
    
    func testRealLocationsJSONStructure() {
        // Given
        let jsonData = """
        [
          {
            "id": "1",
            "name": "Посольство Германии в Душанбе",
            "latitude": 38.5731,
            "longitude": 68.7791
          },
          {
            "id": "2", 
            "name": "Ausländerbehörde Hildburghausen",
            "latitude": 50.4250,
            "longitude": 10.7317
          },
          {
            "id": "3",
            "name": "Bürgeramt Berlin",
            "latitude": 52.5200,
            "longitude": 13.4050
          }
        ]
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let locations = try? decoder.decode([InGermany.Location].self, from: jsonData)
        
        // Then
        XCTAssertNotNil(locations)
        XCTAssertEqual(locations?.count, 3)
        
        // Test first location (Embassy)
        let embassy = locations?[0]
        XCTAssertEqual(embassy?.id, "1")
        XCTAssertEqual(embassy?.name, "Посольство Германии в Душанбе")
        XCTAssertEqual(embassy?.latitude, 38.5731)
        XCTAssertEqual(embassy?.longitude, 68.7791)
        
        // Test second location (Ausländerbehörde)
        let auslaenderbehoerde = locations?[1]
        XCTAssertEqual(auslaenderbehoerde?.id, "2")
        XCTAssertEqual(auslaenderbehoerde?.name, "Ausländerbehörde Hildburghausen")
        XCTAssertEqual(auslaenderbehoerde?.latitude, 50.4250)
        XCTAssertEqual(auslaenderbehoerde?.longitude, 10.7317)
        
        // Test third location (Bürgeramt)
        let buergeramt = locations?[2]
        XCTAssertEqual(buergeramt?.id, "3")
        XCTAssertEqual(buergeramt?.name, "Bürgeramt Berlin")
        XCTAssertEqual(buergeramt?.latitude, 52.5200)
        XCTAssertEqual(buergeramt?.longitude, 13.4050)
    }
    
    // MARK: - Manual Equality Tests
    
    func testLocationManualEquality() {
        // Given
        let location1 = InGermany.Location(
            id: "same-id",
            name: "Location One",
            latitude: 1.0,
            longitude: 1.0
        )
        
        let location2 = InGermany.Location(
            id: "same-id", // Same ID
            name: "Location Two", // Different name
            latitude: 2.0, // Different latitude
            longitude: 2.0 // Different longitude
        )
        
        // When & Then - Manual equality check by ID
        XCTAssertEqual(location1.id, location2.id)
        XCTAssertNotEqual(location1.name, location2.name)
        XCTAssertNotEqual(location1.latitude, location2.latitude)
        XCTAssertNotEqual(location1.longitude, location2.longitude)
    }
    
    func testLocationManualInequality() {
        // Given
        let location1 = InGermany.Location(
            id: "id-1",
            name: "Same Name",
            latitude: 1.0,
            longitude: 1.0
        )
        
        let location2 = InGermany.Location(
            id: "id-2", // Different ID
            name: "Same Name", // Same name
            latitude: 1.0, // Same latitude
            longitude: 1.0 // Same longitude
        )
        
        // When & Then - Manual inequality check by ID
        XCTAssertNotEqual(location1.id, location2.id)
        XCTAssertEqual(location1.name, location2.name)
        XCTAssertEqual(location1.latitude, location2.latitude)
        XCTAssertEqual(location1.longitude, location2.longitude)
    }
    
    // MARK: - Coordinate Validation Tests
    
    func testValidCoordinateRange() {
        // Given - Valid coordinates
        let validLocation1 = InGermany.Location(
            id: "valid-1",
            name: "Valid North",
            latitude: 90.0, // Maximum latitude
            longitude: 0.0
        )
        
        let validLocation2 = InGermany.Location(
            id: "valid-2",
            name: "Valid South",
            latitude: -90.0, // Minimum latitude
            longitude: 0.0
        )
        
        let validLocation3 = InGermany.Location(
            id: "valid-3",
            name: "Valid East",
            latitude: 0.0,
            longitude: 180.0 // Maximum longitude
        )
        
        let validLocation4 = InGermany.Location(
            id: "valid-4",
            name: "Valid West",
            latitude: 0.0,
            longitude: -180.0 // Minimum longitude
        )
        
        // When & Then - All should create valid coordinates
        XCTAssertEqual(validLocation1.coordinate.latitude, 90.0)
        XCTAssertEqual(validLocation2.coordinate.latitude, -90.0)
        XCTAssertEqual(validLocation3.coordinate.longitude, 180.0)
        XCTAssertEqual(validLocation4.coordinate.longitude, -180.0)
    }
    
    func testExtremeCoordinates() {
        // Given - Extreme but valid coordinates
        let northPole = InGermany.Location(
            id: "north-pole",
            name: "North Pole",
            latitude: 90.0,
            longitude: 0.0
        )
        
        let southPole = InGermany.Location(
            id: "south-pole",
            name: "South Pole",
            latitude: -90.0,
            longitude: 0.0
        )
        
        let internationalDateLine = InGermany.Location(
            id: "date-line",
            name: "International Date Line",
            latitude: 0.0,
            longitude: 180.0
        )
        
        // When & Then
        XCTAssertEqual(northPole.coordinate.latitude, 90.0)
        XCTAssertEqual(southPole.coordinate.latitude, -90.0)
        XCTAssertEqual(internationalDateLine.coordinate.longitude, 180.0)
    }
    
    // MARK: - Performance Tests
    
    func testCoordinateComputationPerformance() {
        let location = InGermany.Location(
            id: "perf-test",
            name: "Performance Test",
            latitude: 52.5200,
            longitude: 13.4050
        )
        
        measure {
            for _ in 0..<10000 {
                _ = location.coordinate
            }
        }
    }
    
    func testLocationDecodingPerformance() {
        let json = """
        {
            "id": "perf-test",
            "name": "Performance Test Location",
            "latitude": 48.1351,
            "longitude": 11.5820
        }
        """.data(using: .utf8)!
        
        measure {
            for _ in 0..<1000 {
                let decoder = JSONDecoder()
                _ = try? decoder.decode(InGermany.Location.self, from: json)
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyLocation() {
        // Given
        let emptyLocation = InGermany.Location(
            id: "",
            name: "",
            latitude: 0.0,
            longitude: 0.0
        )
        
        // When & Then
        XCTAssertEqual(emptyLocation.id, "")
        XCTAssertEqual(emptyLocation.name, "")
        XCTAssertEqual(emptyLocation.latitude, 0.0)
        XCTAssertEqual(emptyLocation.longitude, 0.0)
        XCTAssertEqual(emptyLocation.coordinate.latitude, 0.0)
        XCTAssertEqual(emptyLocation.coordinate.longitude, 0.0)
    }
    
    func testLocationWithSpecialCharacters() {
        // Given
        let specialLocation = InGermany.Location(
            id: "special-chars",
            name: "Локация с 🗺️ эмодзи и Café München",
            latitude: 48.1351,
            longitude: 11.5820
        )
        
        // When & Then
        XCTAssertEqual(specialLocation.name, "Локация с 🗺️ эмодзи и Café München")
        XCTAssertEqual(specialLocation.coordinate.latitude, 48.1351)
        XCTAssertEqual(specialLocation.coordinate.longitude, 11.5820)
    }
    
    func testLocationWithPreciseCoordinates() {
        // Given - Coordinates with high precision
        let preciseLocation = InGermany.Location(
            id: "precise",
            name: "Precise Coordinates",
            latitude: 52.51861111111111,
            longitude: 13.40833333333333
        )
        
        // When & Then
        let coordinate = preciseLocation.coordinate
        XCTAssertEqual(coordinate.latitude, 52.51861111111111, accuracy: 0.00000000000001)
        XCTAssertEqual(coordinate.longitude, 13.40833333333333, accuracy: 0.00000000000001)
    }
    
    func testMultipleLocationsWithSameCoordinates() {
        // Given - Different locations with same coordinates
        let location1 = InGermany.Location(
            id: "loc-1",
            name: "Brandenburg Gate",
            latitude: 52.5163,
            longitude: 13.3777
        )
        
        let location2 = InGermany.Location(
            id: "loc-2",
            name: "Reichstag Building",
            latitude: 52.5163, // Same latitude
            longitude: 13.3777 // Same longitude
        )
        
        // When & Then
        XCTAssertEqual(location1.coordinate.latitude, location2.coordinate.latitude)
        XCTAssertEqual(location1.coordinate.longitude, location2.coordinate.longitude)
        XCTAssertNotEqual(location1.id, location2.id)
        XCTAssertNotEqual(location1.name, location2.name)
    }
}

// MARK: - Test Helpers

extension LocationTests {
    private func createLocation(name: String, lat: Double, lon: Double) -> InGermany.Location {
        return InGermany.Location(
            id: "test-\(UUID().uuidString)",
            name: name,
            latitude: lat,
            longitude: lon
        )
    }
}
