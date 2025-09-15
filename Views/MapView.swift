//
//  MapView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

//
//  MapView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI
import MapKit
import CoreLocation

// 🔹 Менеджер для получения текущего местоположения
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
            }
        }
    }
}

struct MapView: View {
    let locations: [Location] = DataService.shared.loadLocations()
    @StateObject private var locationManager = LocationManager()

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4250, longitude: 10.7317),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    var body: some View {
        Group {
            if #available(iOS 17.0, *) {
                Map(initialPosition: .region(region)) {
                    ForEach(locations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            VStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                                Text(location.name)
                                    .font(.caption)
                                    .fixedSize()
                            }
                        }
                    }
                }
            } else {
                Map(coordinateRegion: $region, annotationItems: locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                            Text(location.name)
                                .font(.caption)
                                .fixedSize()
                        }
                    }
                }
            }
        }
        .navigationTitle("Карта")
        .edgesIgnoringSafeArea(.all)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let userLocation = locationManager.userLocation {
                        region.center = userLocation
                        region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    }
                }) {
                    Label("Моё местоположение", systemImage: "location.fill")
                }
            }
        }
    }
}
