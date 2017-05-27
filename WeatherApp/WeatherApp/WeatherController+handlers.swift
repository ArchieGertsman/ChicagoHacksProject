//
//  WeatherController+handlers.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import Foundation
import CoreLocation

extension WeatherController {
    
    func initAppearence() {
        self.view.backgroundColor = .white
    }
    
    func initLocation() {
        // Ask for Authorisation from the User.
        self.location_manager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.location_manager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            location_manager.delegate = self
            location_manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            location_manager.startUpdatingLocation()
        }
    }
    
    func getWeatherData(withURL url: String) {
        let url = URL(string: url)
        
        _ = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error ?? "error fetching weather data")
                } else {
                    do {
                        let parsed_data = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        self.setLabels(with: parsed_data)
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }).resume()
    }
    
    func setLabels(with weather_data: [String:Any]) {
        if let current_data = weather_data["currently"] as? NSDictionary {
            if let temp = current_data["temperature"] as? Double {
                self.current_temperature_label.text = "\(Int(temp))°"
            }
        }
    }
    
    func fahrenheit(fromKelvin k: Double) -> Double {
        return k * (9.0/5.0) - 459.67
    }
    
}

// UIViewController overloads

extension WeatherController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}

// location

extension WeatherController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc_value = manager.location!.coordinate
        
        if  (WeatherController.current_location.coordinate.latitude  != loc_value.latitude) ||
            (WeatherController.current_location.coordinate.longitude != loc_value.longitude)
        {
            WeatherController.current_location = CLLocation(latitude: loc_value.latitude, longitude: loc_value.longitude)
            DispatchQueue.main.async {
                print("\(WeatherController.current_location.coordinate.latitude), \(WeatherController.current_location.coordinate.longitude)")
                let latitude = WeatherController.current_location.coordinate.latitude
                let longitude = WeatherController.current_location.coordinate.longitude
                self.getWeatherData(withURL: "https://api.darksky.net/forecast/\(self.key)/\(latitude),\(longitude)")
            }
        }
    }
    
}
