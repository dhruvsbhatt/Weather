//
//  ViewController.swift
//  Weather
//
//  Created by Dhruv on 10/2/23.
//

import UIKit
import Kingfisher
import CoreLocation
import DBWeather

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {

    let searchController = UISearchController()
    var weather: ResponseBody?
    
    @IBOutlet weak var vwStackWeatherDetails: UIStackView!
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblWindspeed: UILabel!
    @IBOutlet weak var lblMaxTemp: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var vwWelcomeMsg: UIView!
    @IBOutlet weak var vwCurrentLocation: UIView!
    @IBOutlet weak var vwWeatherDetails: UIView!
    
    @IBOutlet weak var lblPlaceName: UILabel!
    @IBOutlet weak var lblCurrentTemperature: UILabel!
    @IBOutlet weak var imgVwWeatherIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather"
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        if UIWindow.isLandscape {
            vwStackWeatherDetails.axis = .horizontal
        }
        if let savedPerson = UserDefaults.standard.object(forKey: "StoredWeather") as? Data {
            let decoder = JSONDecoder()
            if let storedWeather = try? decoder.decode(ResponseBody.self, from: savedPerson) {
                populateData(weatherData: storedWeather)
            }
        }
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            do {
                guard let result = try await DBWeatherKit.shared.getCurrentWeatherForPlace(placeName: searchBar.text!) as? Data else {
                    return
                }
                weather = try JSONDecoder().decode(ResponseBody.self, from: result)
                
                if let objWeather = weather {
                    populateData(weatherData: objWeather)
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(objWeather) {
                        let defaults = UserDefaults.standard
                        defaults.set(encoded, forKey: "StoredWeather")
                    }
                }
            } catch {
                print("Error getting weather: \(error)")
            }
        }
    }
    
    func populateData(weatherData: ResponseBody) {
        lblPlaceName.text = weatherData.name
        lblCurrentTemperature.text = weatherData.main.feelsLike.roundFahrenheitDouble() + "°F  " + weatherData.main.feelsLike.roundDouble() + "°C"
        lblMinTemp.text = "Min temp: " + weatherData.main.tempMin.roundDouble() + "°"
        lblMaxTemp.text = "Max temp: " + weatherData.main.tempMax.roundDouble() + "°"
        lblHumidity.text = "Humidity: " + weatherData.main.humidity.roundDouble() + "%"
        lblWindspeed.text = "Wind speed: " + weatherData.wind.speed.roundDouble() + "m/s"
        
        if weatherData.weather.count > 0 {
            let icon = weatherData.weather[0].icon
            let url = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
            imgVwWeatherIcon.kf.setImage(with: url)
        }
        
    }
    
    @IBAction func btnActionGetCurrentLocation(_ sender: Any) {
        let manager = CLLocationManager()
        manager.delegate = self
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            do {
                guard let result = try await DBWeatherKit.shared.getCurrentWeather(latitude: locations.first!.coordinate.latitude, longitude: locations.first!.coordinate.longitude) as? Data else {
                    return
                }
                weather = try JSONDecoder().decode(ResponseBody.self, from: result)
                if let objWeather = weather {
                    populateData(weatherData: objWeather)
                    let encoder = JSONEncoder()
                    if let encoded = try? encoder.encode(objWeather) {
                        let defaults = UserDefaults.standard
                        defaults.set(encoded, forKey: "StoredWeather")
                    }
                }
            } catch {
                print("Error getting weather: \(error)")
            }
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location", error)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            vwStackWeatherDetails.axis = .horizontal
        } else {
            vwStackWeatherDetails.axis = .vertical
        }
    }
}

