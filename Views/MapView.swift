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
    @State private var locations: [Location] = []
    @StateObject private var locationManager = LocationManager()
    @State private var isLoading = true
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "ru"

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4250, longitude: 10.7317),
        span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0)
    )

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView(getTranslation(key: "Загрузка карты...", language: selectedLanguage))
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
            .navigationTitle(getTranslation(key: "Карта", language: selectedLanguage))
            .edgesIgnoringSafeArea(.all)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let userLocation = locationManager.userLocation {
                            region.center = userLocation
                            region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                        }
                    }) {
                        Label(getTranslation(key: "Моё местоположение", language: selectedLanguage), systemImage: "location.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await refreshLocations()
                        }
                    }) {
                        Label(getTranslation(key: "Обновить", language: selectedLanguage), systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadLocations()
            }
        }
    }
    
    private func loadLocations() async {
        locations = await DataService.shared.loadLocations()
        isLoading = false
    }
    
    private func refreshLocations() async {
        isLoading = true
        await DataService.shared.refreshData()
        locations = await DataService.shared.loadLocations()
        isLoading = false
    }

    // MARK: - Translation
    private func getTranslation(key: String, language: String) -> String {
        let translations: [String: [String: String]] = [
            "Загрузка карты...": [
                "ru": "Загрузка карты...",
                "en": "Loading map...",
                "de": "Karte wird geladen...",
                "tj": "Боркунии харита...",
                "fa": "در حال بارگذاری نقشه...",
                "ar": "جارٍ تحميل الخريطة...",
                "uk": "Завантаження карти..."
            ],
            "Карта": [
                "ru": "Карта",
                "en": "Map",
                "de": "Karte",
                "tj": "Харита",
                "fa": "نقشه",
                "ar": "خريطة",
                "uk": "Карта"
            ],
            "Моё местоположение": [
                "ru": "Моё местоположение",
                "en": "My location",
                "de": "Mein Standort",
                "tj": "Ҷойгиршавии ман",
                "fa": "مکان من",
                "ar": "موقعي",
                "uk": "Моє місцезнаходження"
            ],
            "Обновить": [
                "ru": "Обновить",
                "en": "Refresh",
                "de": "Aktualisieren",
                "tj": "Навсозӣ",
                "fa": "به‌روزرسانی",
                "ar": "تحديث",
                "uk": "Оновити"
            ]
        ]
        return translations[key]?[language] ?? key
    }
}
