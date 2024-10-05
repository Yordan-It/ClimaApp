import Foundation

/// A model that represents weather information.
///
/// The `Weather` class conforms to the `Decodable` protocol, allowing it to
/// be easily decoded from a JSON structure. It contains properties such as
/// the city, country, temperature, and a description of the weather.
final class Weather: Decodable {
    
    /// The name of the city.
    let city: String
    
    /// The country code (e.g., "US" for the United States).
    let country: String
    
    /// The temperature in Celsius.
    let temperature: Double
    
    /// A brief description of the current weather (e.g., "Clear", "Cloudy").
    let description: String
    
    /// Enum that defines the coding keys used to map the JSON fields
    /// to the properties of the `Weather` class.
    enum CodingKeys: String, CodingKey {
        case city = "name"
        case country = "sys"
        case temperature = "main"
        case description = "weather"
    }
    
    /// A nested struct that represents the system information from the JSON, particularly the country.
    struct Sys: Decodable {
        /// The country code (e.g., "US").
        let country: String
    }

    /// A nested struct that represents the temperature information from the JSON.
    struct Main: Decodable {
        /// The temperature in Celsius.
        let temp: Double
    }

    /// A nested struct that represents the weather description from the JSON.
    struct WeatherDescription: Decodable {
        /// A short description of the current weather (e.g., "Clear").
        let main: String
    }

    /// The initializer required by the `Decodable` protocol to decode
    /// the JSON data into a `Weather` instance.
    ///
    /// - Parameter decoder: A decoder to read data from.
    /// - Throws: An error if any values are missing or cannot be decoded.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the city name
        city = try container.decode(String.self, forKey: .city)
        
        // Decode the country from the "sys" part of the JSON
        let sysContainer = try container.decode(Sys.self, forKey: .country)
        country = sysContainer.country
        
        // Decode the temperature from the "main" part of the JSON
        let mainContainer = try container.decode(Main.self, forKey: .temperature)
        temperature = mainContainer.temp
        
        // Decode the weather description from the "weather" array in the JSON
        var weatherArray = try container.nestedUnkeyedContainer(forKey: .description)
        let weather = try weatherArray.decode(WeatherDescription.self)
        description = weather.main
    }
}


