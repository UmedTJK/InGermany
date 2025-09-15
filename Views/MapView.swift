//
//  MapView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI
import MapKit

struct MapView: View {
    // Тестовые точки (можно будет подгружать из JSON)
    let locations: [Location] = [
        Location(
            name: "Посольство Германии в Душанбе",
            latitude: 38.5731, longitude: 68.7791
        ),
        Location(
            name: "Ausländerbehörde Hildburghausen",
            latitude: 50.4250, longitude: 10.7317
        ),
        Location(
            name: "Bürgeramt Berlin",
            latitude: 52.5200, longitude: 13.4050
        )
    ]

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4250, longitude: 10.7317),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    var body: some View {
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
        .navigationTitle("Карта")
        .edgesIgnoringSafeArea(.all)
    }
}
