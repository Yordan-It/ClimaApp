import Foundation
import Combine

/// A service that fetches weather data for a given city using the OpenWeatherMap API.
class WeatherService {
    /// The API key used for accessing the OpenWeatherMap API.
    private let apiKey = "d0459cc3ebd0891e83b2df1b9e771c6d"
    
    /// A cache for storing weather data to avoid unnecessary network requests.
    private var cache = NSCache<NSString, Weather>()
    
    /**
     Fetches weather data for a specified city.
     
     This method first checks if the weather data for the requested city is already in the cache. If it is, it returns the cached data. Otherwise, it performs a network request to the OpenWeatherMap API to fetch the latest weather information.

     - Parameter city: The name of the city for which to fetch weather data.
     - Returns: A publisher that emits a `Weather` object or an `Error` if the operation fails.
     
     - Note: The weather data is cached after a successful network request.
     
     # Example Usage:
     ```
     let weatherService = WeatherService()
     weatherService.fetchWeather(for: "London")
         .sink(receiveCompletion: { completion in
             switch completion {
             case .finished:
                 print("Weather data fetched successfully")
             case .failure(let error):
                 print("Error fetching weather: \(error)")
             }
         }, receiveValue: { weather in
             print(weather)
         })
         .store(in: &cancellables)
     ```
     */
    func fetchWeather(for city: String) -> AnyPublisher<Weather, Error> {
        let cityKey = NSString(string: city)
        
        // Return cached data if available
        if let cachedWeather = cache.object(forKey: cityKey) {
            return Just(cachedWeather)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // Ensure the city name can be encoded for a URL
        guard let cityEncoded = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            fatalError("City name could not be encoded")
        }
        
        // Construct the API URL string
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityEncoded)&appid=\(apiKey)&units=metric"
        print("URL construida: \(urlString)")
        
        // Ensure the URL is valid
        guard let url = URL(string: urlString) else {
            fatalError("URL is not valid: \(urlString)")
        }
        
        // Perform the network request and cache the result
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Weather.self, decoder: JSONDecoder())
            .handleEvents(receiveOutput: { [weak self] weather in
                self?.cache.setObject(weather, forKey: cityKey)
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

