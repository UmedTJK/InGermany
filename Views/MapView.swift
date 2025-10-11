//
//  MapView.swift
//  InGermany
//

import SwiftUI
import MapKit
import CoreLocation

/// A manager responsible for requesting location permissions and tracking the user's current location.
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

/// A view that displays a map with annotations for predefined locations and provides controls for user location and refreshing.
struct MapView: View {
    @State private var locations: [Location] = []
    @StateObject private var locationManager = LocationManager()
    @State private var isLoading = true
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4250, longitude: 10.7317),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    @EnvironmentObject private var appContainer: AppContainer

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView(t("map_loading"))
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
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
                }
            }
            .navigationTitle(t("map_title"))
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let userLocation = locationManager.userLocation {
                            region.center = userLocation
                            region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        }
                    }) {
                        Label(t("map_my_location"), systemImage: "location.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await refreshLocations()
                        }
                    }) {
                        Label(t("map_refresh"), systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadLocations()
            }
        }
    }
    
    private func loadLocations() async {
        locations = await appContainer.dataService.loadLocations()
        isLoading = false
    }
    
    private func refreshLocations() async {
        isLoading = true
        await appContainer.dataService.refreshData()
        locations = await appContainer.dataService.loadLocations()
        isLoading = false
    }

    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    MapView()
        .environmentObject(AppContainer.previewMock())
}
