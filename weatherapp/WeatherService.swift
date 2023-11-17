import UIKit
import CoreLocation

class WeatherService {
    static let shared = WeatherService()
    
    let apiKey = "1057407132ab452eb0dc3ce65142ce57"
    let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather(urlString: String, completion: @escaping (Result<WeatherResponseWrapper, Error>) -> Void) {
        print(urlString)
        
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    do {
                        let weatherData = try JSONDecoder().decode(WeatherResponseWrapper.self, from: data)
                        completion(.success(weatherData))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }.resume()
        }
    }
    
    func getCurrentLocationWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponseWrapper, Error>) -> Void) {
        let urlString = "\(baseUrl)?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        fetchWeather(urlString: urlString) { result in
            switch result {
            case .success(let weatherData):
                completion(.success(weatherData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getWeatherData(city: String, completion: @escaping (Result<WeatherResponseWrapper, Error>) -> Void) {
        let cityEscaped = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "\(baseUrl)?q=\(cityEscaped)&appid=\(apiKey)&units=metric"
        
        fetchWeather(urlString: urlString) { result in
            switch result {
            case .success(let weatherData):
                completion(.success(weatherData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
            
            
// Model of the response body we get from calling the OpenWeather API
struct WeatherResponseWrapper: Decodable {
    var coord: CoordinatesResponse
    var weather: [WeatherResponse]
    var main: MainResponse
    var name: String
    var wind: WindResponse
    var dt: Int64
    var sys: SysResponse
    var timezone: Int
    
    struct CoordinatesResponse: Decodable {
        var lon: Double
        var lat: Double
    }
    
    struct WeatherResponse: Decodable {
        var id: Double
        var main: String
        var description: String
        var icon: String
    }
    
    struct MainResponse: Decodable {
        var temp: Double
        var feels_like: Double
        var temp_min: Double
        var temp_max: Double
        var pressure: Double
        var humidity: Double
    }
    
    struct WindResponse: Decodable {
        var speed: Double
        var deg: Double
    }
    
    struct SysResponse: Decodable {
        var sunrise: Int64
        var country: String
    }
}



