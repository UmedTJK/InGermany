//
//  MapView.swift
//  InGermany
//
//  Created by SUM TJK on 15.09.25.
//

import SwiftUI
import MapKit
import CoreLocation

/// A manager responsible for requesting location permissions and tracking the user's current location.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    /// The current user location coordinates, updated when the location changes.
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
    /// The list of locations to be displayed on the map.
    @State private var locations: [Location] = []
    /// The location manager used to retrieve and observe the user's current location.
    @StateObject private var locationManager = LocationManager()
    /// A flag indicating whether the map is currently loading data.
    @State private var isLoading = true
    /// The current language setting used for localizing map UI text.
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"
    /// The current visible region of the map.
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4250, longitude: 10.7317),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )
    /// Контейнер зависимостей для получения сервисов.
    @EnvironmentObject private var appContainer: AppContainer

    /// Builds the main map view with navigation, annotations, and toolbar controls.
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView(t("Загрузка карты..."))
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
            .navigationTitle(t("Карта"))
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let userLocation = locationManager.userLocation {
                            region.center = userLocation
                            region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        }
                    }) {
                        Label(t("Моё местоположение"), systemImage: "location.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await refreshLocations()
                        }
                    }) {
                        Label(t("Обновить"), systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadLocations()
            }
        }
    }
    
    /// Loads locations asynchronously from the data service and updates the map.
    private func loadLocations() async {
        locations = await appContainer.dataService.loadLocations()
        isLoading = false
    }
    
    /// Refreshes locations by clearing cache, reloading data, and updating the map.
    private func refreshLocations() async {
        isLoading = true
        await appContainer.dataService.refreshData()
        locations = await appContainer.dataService.loadLocations()
        isLoading = false
    }

    /// Shortcut helper for retrieving localized translations via AppContainer's LocalizationManager.
    private func t(_ key: String) -> String {
        appContainer.localizationManager.getTranslation(key: key, language: selectedLanguage)
    }
}

// MARK: - Preview
#Preview {
    MapView()
        .environmentObject(AppContainer.previewMock())
}
