//
//  ViewController.swift
//  weatherapp
//
//  Created by Chiree Sherpa on 2023-11-13.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var btnCurrentLocation: UIImageView!
    
    @IBOutlet weak var searchBar: UITextField!
    
    @IBOutlet weak var btnSearch: UIImageView!
    
    @IBOutlet weak var labelLocation: UILabel!
    
    @IBOutlet weak var labelDatetime: UILabel!
    
    @IBOutlet weak var imageWeather: UIImageView!
    
    @IBOutlet weak var labelTemperature: UILabel!
    
    @IBOutlet weak var btnToggleTemp: UISwitch!
    
    @IBOutlet weak var labelWeatherInfo: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var temperature : Double?
    
    let locationManager = CLLocationManager()
    
    var weatherInfo: [[String : String]] = [
        [
            "label": "WIND",
            "value": "6:00",
            "icon": "windy"
        ]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        searchBar.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        // Adding tap gesture to currentLocaitonImageView
        let currentLocaitonTapGesture = UITapGestureRecognizer(target: self, action: #selector(currentLocationImageTapped))
        btnCurrentLocation.addGestureRecognizer(currentLocaitonTapGesture)
        
        
        // Adding tap guesture to searchImageView
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(searchImageTapped))
        btnSearch.addGestureRecognizer(searchTapGesture)

        // Adding toggle change handler to switch
        btnToggleTemp.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchImageTapped()
        return true
    }

    // handling the toggle for temperature unit
    @objc func switchValueChanged(_ sender: UISwitch) {
        var tempText: String
        if sender.isOn {
            temperature = (temperature! - 32) * 5/9;
            tempText = "\(String(format: "%.2f", temperature!))°C"
        } else {
            temperature = (temperature! * 9/5) + 32;
            tempText = "\(String(format: "%.2f", temperature!))°F"
        }
        labelTemperature.text = tempText
    }
    
    // handling on current location weather button tap
    @objc func currentLocationImageTapped() {
        // Handle the tap on the image view
        
        print("Current Location tapped!")
        locationManager.requestLocation()
        // You can perform any action here in response to the tap
    }
    
    // handlin on search btn tap
    @objc func searchImageTapped() {
        // Handle the tap on the image view
        print("Search tapped!")
        print(searchBar.text!)
        
        WeatherService.shared.getWeatherData(city: searchBar.text!) { result in
            switch result {
            case .success(let weatherData):
                // Handle successful weather data retrieval
                print("Weather Data: \(weatherData.coord)")
                
                self.setUI(data: weatherData)
                self.updateDataSource(data: weatherData)
                
                // Update UI with weather information
            case .failure(let error):
                // Handle error
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    func getTimeFromTimestamp(timestamp: Int, secondsFromGMT: Int) -> String{
        let timezone = TimeZone(secondsFromGMT: secondsFromGMT)
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // "EEEE" for the day of the week, "h" for the hour, "mm" for the minutes, "a" for AM/PM
        dateFormatter.locale = Locale(identifier: "en_US") // Set locale for English format
        dateFormatter.timeZone = timezone

        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func updateDataSource(data: WeatherResponseWrapper) {
        self.weatherInfo.removeAll()
        let sunrise = getTimeFromTimestamp(timestamp: data.sys.sunrise, secondsFromGMT: data.timezone)
        let sunset = getTimeFromTimestamp(timestamp: data.sys.sunset, secondsFromGMT: data.timezone)
        
        self.weatherInfo.append([
            "label": "SUNRISE",
            "value": sunrise,
            "icon": "sunrise"
        ])
        
        self.weatherInfo.append([
            "label": "WIND",
            "value": String(data.wind.speed) + " m/s",
            "icon": "wind"
        ])
        
        self.weatherInfo.append([
            "label": "FEELS LIKE",
            "value": String(data.main.feels_like) + "°C",
            "icon": "thermometer"
        ])
        
        self.weatherInfo.append([
            "label": "PRESSURE",
            "value": String(data.main.pressure) + "N/m2",
            "icon": "pressure"
        ])
        
        self.weatherInfo.append([
            "label": "HUMIDITY",
            "value": String(data.main.humidity) + "%",
            "icon": "humidity"
        ])
        
        self.weatherInfo.append([
            "label": "SUNSET",
            "value": sunset,
            "icon": "sunset"
        ])
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
       }
        print(self.weatherInfo)
    }
    
    // updating ui after receiving api response
    func setUI(data: WeatherResponseWrapper) {
        DispatchQueue.global().async {
            // running task in main thread asynchronously
            DispatchQueue.main.async {
                self.labelLocation.text = "\(data.name), \(data.sys.country)"
   
                self.labelTemperature.text = String(data.main.temp) + "°C"
                self.labelWeatherInfo.text = data.weather[0].main
                print(data.weather[0].icon)
                self.imageWeather.image = UIImage(named: data.weather[0].icon)
                
                let date = Date(timeIntervalSince1970: TimeInterval(data.dt))
                let dateFormatter = DateFormatter()
                let timezone = TimeZone(secondsFromGMT: data.timezone)
                
                dateFormatter.timeZone = timezone
                dateFormatter.dateFormat = "EEEE h:mm a"
                // "EEEE" for the day of the week, "h" for the hour, "mm" for the minutes, "a" for AM/PM
                dateFormatter.locale = Locale(identifier: "en_US") 
                // Setting locale for English format

                let dateString = dateFormatter.string(from: date)
                self.labelDatetime.text = dateString
                
                self.temperature = data.main.temp

            }
        }
    }
    
    // update weather image by fetching image from open weather api
    func updateWeatherImage(imageName: String)  {
        let imageUrlString = "https://openweathermap.org/img/wn/\(imageName)@4x.png"
        
        if let imageUrl = URL(string: imageUrlString) {
            // Create a URLSession
            let session = URLSession.shared
            
            // Create a data task using the session
            let task = session.dataTask(with: imageUrl) { (data, response, error) in
                // Check if there's an error or if data is nil
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("No data or unable to create image from data")
                    return
                }
                
                DispatchQueue.main.async {
                   self.imageWeather.image = image
               }
            }
            
            // Start the data task
            task.resume()
        }
    }
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionCell
        cell.iconView.image = UIImage(named: weatherInfo[indexPath.row]["icon"]!)
        cell.labelProperty.text = weatherInfo[indexPath.row]["label"]!
        cell.labelValue.text = weatherInfo[indexPath.row]["value"]!
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Set custom insets for the first cell
        let defaultInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) // Adjust the default insets

        if section == 0 { // Assuming the section containing your first cell is 0
            print("hi")
            return UIEdgeInsets(top: defaultInsets.top, left: 10, bottom: defaultInsets.bottom, right: defaultInsets.right)
            // Set different trailing inset for the first cell
        }

        return defaultInsets // Return default insets for other cells
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    // implementing the locationManager function for success case
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            WeatherService.shared.getCurrentLocationWeather(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let weatherData):
                    // Handle successful weather data retrieval
                    print("Weather Data: \(weatherData.coord)")
                    
                    self.setUI(data: weatherData)
                    self.updateDataSource(data: weatherData)
                    
                    // Update UI with weather information
                case .failure(let error):
                    // Handle error
                    print("Error fetching weather: \(error)")
                }
            }
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    // implementing the on error locationManager function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
    }
}


