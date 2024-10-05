import SwiftUI

/// The main content view for displaying the weather information and managing favorite cities.
struct ContentView: View {
    /// The view model that handles weather data and favorite cities.
    @ObservedObject var viewModel = WeatherViewModel()
    
    /// The scale of the button, used for creating an animation effect when clicked.
    @State private var buttonScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            /// A background gradient for aesthetic appeal.
            LinearGradient(gradient: Gradient(colors: [Color("PrimaryBackground"), Color("SecondaryBackground")]),
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                /// Input field and button section.
                VStack(spacing: 20) {
                    /// A text field for entering the name of the city.
                    TextField(NSLocalizedString("EnterCity", comment: ""), text: $viewModel.city, onCommit: {
                        viewModel.fetchWeather()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                    .padding(.horizontal)
                    
                    /// A button for adding the current city to the list of favorites.
                    Button(action: {
                        viewModel.addFavoriteCity()
                        withAnimation(.easeIn(duration: 0.2)) {
                            buttonScale = 1.2
                        }
                        withAnimation(.easeOut(duration: 0.2).delay(0.2)) {
                            buttonScale = 1.0
                        }
                    }) {
                        Text(NSLocalizedString("AddToFavorites", comment: ""))
                            .font(.system(size: 14))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .scaleEffect(buttonScale)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                /// Displays the weather information if available.
                if let weather = viewModel.weather {
                    VStack(spacing: 10) {
                        /// Displays the city and country of the weather data.
                        Text("\(weather.city), \(weather.country)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        
                        /// Displays the temperature in Celsius.
                        Text("\(weather.temperature, specifier: "%.1f")°C")
                            .font(.system(size: 70))
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            /// Displays the translated weather description.
                            Text(translatedWeatherDescription(for: weather.description))
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                            
                            /// Displays an appropriate weather icon based on the weather description.
                            Image(systemName: weatherIcon(for: weather.description))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                } else {
                    /// Displays a message when no weather data is available.
                    Text(NSLocalizedString("NoDataAvailable", comment: ""))
                        .foregroundColor(.white.opacity(0.7))
                        .padding()
                }
                
                /// Displays the list of favorite cities and allows users to select or remove them.
                FavoritePlacesList(
                    favoriteCities: $viewModel.favoriteCities,
                    removeCity: { index in
                        viewModel.removeFavoriteCity(at: index)
                    },
                    selectCity: { city in
                        viewModel.city = city
                        viewModel.fetchWeather()
                    }
                )
            }
            .padding(.bottom, 20)
        }
        .alert(isPresented: $viewModel.showAlert) {
            /// An alert that appears when an error occurs.
            Alert(title: Text(NSLocalizedString("ErrorTitle", comment: "")),
                  message: Text(viewModel.alertMessage),
                  dismissButton: .default(Text("OK")))
        }
        .onAppear {
            /// Fetches the weather for the default city when the view appears.
            viewModel.fetchWeather()
        }
    }
}

/// Translates the weather description into the current locale.
/// - Parameter description: The original weather description string.
/// - Returns: A localized weather description string.
func translatedWeatherDescription(for description: String) -> String {
    let normalDescription = description.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return NSLocalizedString(normalDescription, comment: "")
}

/// Returns an appropriate weather icon based on the weather description.
/// - Parameter description: The weather description string.
/// - Returns: A system image name that represents the weather condition.
func weatherIcon(for description: String) -> String {
    let normalDescription = description.lowercased()
    
    switch normalDescription {
    case "clear", "despejado":
        return "sun.max.fill"
    case "clouds", "nublado":
        return "cloud.fill"
    case "few clouds", "pocas nubes", "partly cloudy", "parcialmente nublado", "scattered clouds", "nubes dispersas":
        return "cloud.sun.fill"
    case "rain", "lluvia":
        return "cloud.rain.fill"
    case "thunderstorm", "tormenta eléctrica":
        return "cloud.bolt.rain.fill"
    case "snow", "nieve":
        return "snow"
    case "mist", "fog", "niebla":
        return "cloud.fog.fill"
    default:
        return "cloud.fill"
    }
}

/// A view that displays a list of favorite cities.
/// Allows users to select or remove a favorite city.
struct FavoritePlacesList: View {
    /// A binding to the array of favorite cities.
    @Binding var favoriteCities: [String]
    
    /// The closure to execute when removing a city from the list.
    var removeCity: (Int) -> Void
    
    /// The closure to execute when selecting a city.
    var selectCity: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("FavoritePlaces")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(Color("PrimaryText"))
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
            
            /// A list of favorite cities with options to select or remove each city.
            List {
                ForEach(favoriteCities.indices, id: \.self) { index in
                    HStack {
                        Button(action: {
                            selectCity(favoriteCities[index])
                        }) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .padding(.trailing, 8)
                                
                                Text(favoriteCities[index])
                                    .foregroundColor(Color(.white))
                                    .font(.body)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color("SecondaryBackground"))
                            .cornerRadius(8)
                            .shadow(radius: 3)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            removeCity(index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .listRowBackground(Color("clear"))
                }
            }
            .listStyle(PlainListStyle())
            .background(Color("SecondaryBackground"))
            .scrollContentBackground(.automatic)
        }
        .background(Color("SecondaryBackground"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

