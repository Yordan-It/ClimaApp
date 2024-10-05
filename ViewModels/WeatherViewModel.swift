import Foundation
import Combine

/// ViewModel that handles fetching weather data and managing favorite cities.
class WeatherViewModel: ObservableObject {
    /// The current weather information for the selected city.
    @Published var weather: Weather?
    
    /// The name of the city for which to fetch weather data. Defaults to "New York".
    @Published var city: String = "New York"
    
    /// A list of the user's favorite cities.
    @Published var favoriteCities: [String] = []
    
    /// A boolean indicating whether an alert should be displayed.
    @Published var showAlert: Bool = false
    
    /// The message to be shown in the alert.
    @Published var alertMessage: String = ""
    
    /// A set of cancellables to manage Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()
    
    /// The service responsible for fetching weather data.
    private let weatherService = WeatherService()
    
    /// The key used to store favorite cities in `UserDefaults`.
    private let favoritesKey = "favoriteCities"
    
    /// Initializes the ViewModel and loads the favorite cities from `UserDefaults`.
    init() {
        loadFavoriteCities()
    }
    
    /**
     Fetches the weather data for the currently selected city.
     
     This method interacts with the `WeatherService` to retrieve weather data for the city stored in the `city` property. If the request fails, an alert is triggered with an appropriate error message.
     
     - Note: The fetched weather data is stored in the `weather` property and triggers a UI update.
     */
    func fetchWeather() {
        weatherService.fetchWeather(for: city)
            .sink(receiveCompletion: { [ weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.alertMessage = "Failed to fetch weather: \(error.localizedDescription)"
                    self?.showAlert = true
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] weather in
                self?.weather = weather
            })
            .store(in: &cancellables)
    }
    
    /**
     Adds the current city to the list of favorite cities.
     
     This method checks if the `city` is already in the `favoriteCities` list. If not, it adds the city and saves the updated list to `UserDefaults`. If the city is already in the list, an alert is shown with a localized message.
     
     - Note: This method triggers a UI alert if the city is already a favorite.
     */
    func addFavoriteCity() {
        if !favoriteCities.contains(city) {
            favoriteCities.append(city)
            saveFavoriteCities()
        } else {
            alertMessage = NSLocalizedString("DupliteCityMessage", comment: "")
            showAlert = true
        }
    }
    
    /**
     Removes a city from the list of favorite cities.
     
     - Parameter index: The index of the city to remove from the `favoriteCities` list.
     
     This method removes a city at the specified index from the `favoriteCities` array and saves the updated list to `UserDefaults`.
     
     - Note: This method performs bounds checking to ensure the index is valid.
     */
    func removeFavoriteCity(at index: Int) {
        guard index >= 0 && index < favoriteCities.count else { return }
        favoriteCities.remove(at: index)
        saveFavoriteCities()
    }
    
    /// Saves the favorite cities list to `UserDefaults`.
    private func saveFavoriteCities() {
        UserDefaults.standard.set(favoriteCities, forKey: favoritesKey)
    }
    
    /// Loads the favorite cities list from `UserDefaults`. If no cities are found, the list is initialized as an empty array.
    private func loadFavoriteCities() {
        favoriteCities = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }
}



