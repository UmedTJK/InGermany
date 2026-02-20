import SwiftUI

@MainActor
final class LocationsViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading: Bool = false
    
    private let dataService: DataServiceProtocol

    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    func loadLocations() async {
        isLoading = true
        defer { isLoading = false }
        
        locations = await dataService.loadLocations()
    }
}
