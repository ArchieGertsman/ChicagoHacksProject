//
//  WeatherController+handlers.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import Foundation
import CoreLocation
import NotificationCenter

extension WeatherController {
    
    func initAppearence() {
        let current_hour = Calendar.current.component(.hour, from: Date())
        
        let latitude = WeatherController.current_location.latitude
        let longitude = WeatherController.current_location.longitude
        
        print("https://api.darksky.net/forecast/\(WeatherController.key)/\(latitude),\(longitude)")
        
        WeatherController.getWeatherData(withURL: "https://api.darksky.net/forecast/\(WeatherController.key)/\(latitude),\(longitude)", completion: { (data) in
            
            guard let current_data = data["currently"] as? NSDictionary else { return }
            guard let precip = current_data["icon"] as? String else { return }
            guard let temp = current_data["temperature"] as? Double else { return }
            guard let apparent_temp = current_data["apparentTemperature"] as? Double else { return }
            guard let percip_chance = current_data["precipProbability"] as? Double else { return }
            guard let humidity = current_data["humidity"] as? Double else { return }
            guard let wind_speed = current_data["windSpeed"] as? Double else { return }
            
            self.current_temperature = temp
            self.feels_like_temperature = apparent_temp
            self.precipitation_chance = percip_chance
            self.humidity = humidity
            self.wind_speed = wind_speed
                
            if current_hour >= 5 && current_hour < 7 {
                
                switch precip {
                case "rain", "hail":
                    self.initDetails("Rain", #imageLiteral(resourceName: "Rain"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "snow", "sleet":
                    self.initDetails("Snow", #imageLiteral(resourceName: "Snow"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "cloudy":
                    self.initDetails("Cloudy", #imageLiteral(resourceName: "Clouds"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                case "partly-cloudy-day":
                    self.initDetails("Partly Cloudy", #imageLiteral(resourceName: "CloudSun"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                default:
                    self.initDetails("Clear", #imageLiteral(resourceName: "Sun"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                }
                
            }
            else if current_hour >= 7 && current_hour < 18 {
                
                switch precip {
                case "rain", "hail":
                    self.initDetails("Rain", #imageLiteral(resourceName: "Rain"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "snow", "sleet":
                    self.initDetails("Snow", #imageLiteral(resourceName: "Snow"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "cloudy":
                    self.initDetails("Cloudy", #imageLiteral(resourceName: "Clouds"), #imageLiteral(resourceName: "Gradient_Day"))
                case "partly-cloudy-day":
                    self.initDetails("Partly Cloudy", #imageLiteral(resourceName: "CloudSun"), #imageLiteral(resourceName: "Gradient_Day"))
                default:
                    self.initDetails("Sunny", #imageLiteral(resourceName: "Sun"), #imageLiteral(resourceName: "Gradient_Day"))
                }
                
            }
            else if current_hour >= 18 && current_hour < 20 {
                
                switch precip {
                case "rain", "hail":
                    self.initDetails("Rain", #imageLiteral(resourceName: "Rain"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "snow", "sleet":
                    self.initDetails("Snow", #imageLiteral(resourceName: "Snow"), #imageLiteral(resourceName: "Gradient_Rain"))
                case "cloudy":
                    self.initDetails("Cloudy", #imageLiteral(resourceName: "Clouds"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                case "partly-cloudy-day":
                    self.initDetails("Partly Cloudy", #imageLiteral(resourceName: "CloudSun"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                default:
                    self.initDetails("Clear", #imageLiteral(resourceName: "Sun"), #imageLiteral(resourceName: "Gradient_Sunrise"))
                }
                
            }
            else {
                self.initDetails("Night", #imageLiteral(resourceName: "Moon"), #imageLiteral(resourceName: "Gradient_Night"))
            }
            
            // pop-up that describes the event creation error
            let alert = UIAlertController(title: "Hey!", message: self.array[Int(arc4random_uniform(3))], preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Will do!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        })

    }
    
    func configure(withMeasurementSystem system: SettingsController.MeasurementSystem) {
        if system == .imperial {
            // celcius to fahrenheit
            self.current_temperature = fahrenheit(fromCelcius: self.current_temperature)
            self.feels_like_temperature = fahrenheit(fromCelcius: self.feels_like_temperature)
            self.wind_speed = mph(fromKmph: self.wind_speed)
        } else {
            // fahrenheit to celcius
            self.current_temperature = celcius(fromFahrenheit: self.current_temperature)
            self.feels_like_temperature = celcius(fromFahrenheit: self.feels_like_temperature)
            self.wind_speed = kmph(fromMph: self.wind_speed)
        }
    }
    
    func celcius(fromFahrenheit deg: Double) -> Double {
        return (deg - 32.0) * (5.0/9.0)
    }
    
    func fahrenheit(fromCelcius deg: Double) -> Double {
        return deg * (9.0/5.0) + 32.0
    }
    
    func mph(fromKmph s: Double) -> Double {
        return 0.621371 * s
    }
    
    func kmph(fromMph s: Double) -> Double {
        return 1.60934 * s
    }
    
    func initDetails(_ text: String, _ image: UIImage, _ background: UIImage) {
        self.weather_icon_label.text = text
        self.weather_icon_view.image = image
        self.background_image_view.image = background
    }
    
    func prepareView() {
        bottomBar = BottomBar()
        bottomBar.button.addTarget(self, action: #selector(self.bottomButtonTapped), for: .touchUpInside)
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomBar)
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[bottomBar]-0-|", options: [], metrics: nil, views: ["bottomBar": bottomBar]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomBar(\(BottomBar.bottomBarHeight))]-0-|", options: [], metrics: nil, views: ["bottomBar": bottomBar]))
        
        nextViewController = SettingsController()
        nextViewController.rootViewController = self
        nextViewController.transitioningDelegate = self
        nextViewController.modalPresentationStyle = .overCurrentContext
        
        presentInteractor = MiniToLargeViewInteractive()
        presentInteractor.attachToViewController(viewController: self, withView: bottomBar, presentViewController: nextViewController)
        dismissInteractor = MiniToLargeViewInteractive()
        dismissInteractor.attachToViewController(viewController: nextViewController, withView: nextViewController.view, presentViewController: nil)
    }
    
    func bottomButtonTapped() {
        disableInteractivePlayerTransitioning = true
        self.present(nextViewController, animated: true) { [unowned self] in
            self.disableInteractivePlayerTransitioning = false
        }
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
    
    static func getWeatherData(withURL url: String, completion: @escaping (_ data: [String:Any]) -> Void) {
        let url = URL(string: url)
        
        _ = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if error != nil {
                    print(error ?? "error fetching weather data")
                } else {
                    do {
                        let parsed_data = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                        completion(parsed_data)
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
    
    static func getMaxTemp(with weather_data: [String:Any]) -> Int? {
        guard let daily_data = weather_data["daily"] as? NSDictionary else { return nil }
        guard let yesterday_data = daily_data["data"] as? NSArray else { return nil }
        guard let a = yesterday_data[0] as? NSDictionary else { return nil }
        guard let temp = a["temperatureMax"] as? Double else { return nil }
        return Int(temp)
    }
    
    static func getTodaysMessage(completion: @escaping (_ title: String?, _ message: String?) -> Void) {
        let latitude = WeatherController.current_location.latitude
        let longitude = WeatherController.current_location.longitude
        
        let seconds_in_a_day = 60 * 60 * 24
        let yesterday_time = Int(NSDate().timeIntervalSince1970) - seconds_in_a_day
        WeatherController.getWeatherData(withURL: "https://api.darksky.net/forecast/\(WeatherController.key)/\(latitude),\(longitude),\(yesterday_time)", completion: { (yesterday_data) in
            
            guard let yesterday_daily_data = yesterday_data["daily"] as? NSDictionary else { return }
            guard let yesterday_data_node = yesterday_daily_data["data"] as? NSArray else { return }
            guard let yesterday_data_node_entry = yesterday_data_node[0] as? NSDictionary else { return }
            guard let yesterday_max_temp = yesterday_data_node_entry["temperatureMax"] as? Double else { return }
            
            WeatherController.getWeatherData(withURL: "https://api.darksky.net/forecast/\(WeatherController.key)/\(latitude),\(longitude)", completion: { (today_data) in
                
                guard let today_daily_data = today_data["daily"] as? NSDictionary else { return }
                guard let today_data_node = today_daily_data["data"] as? NSArray else { return }
                guard let today_data_node_entry = today_data_node[0] as? NSDictionary else { return }
                guard let today_max_temp = today_data_node_entry["temperatureMax"] as? Double else { return }
                guard let precip = today_data_node_entry["icon"] as? String else { return }
                guard let summary = today_data_node_entry["summary"] as? String else { return }
                
                let today_interval = TempInterval.getInterval(of: Int(today_max_temp))
                let yesterday_interval = TempInterval.getInterval(of: Int(yesterday_max_temp))
                
                let notification_title: String? = "Weather Alert"
                var notification_message: String?
                /*
                if today_interval == yesterday_interval {
                    notification_title = nil
                    notification_message = nil
                }
                else {
                    if abs(today_max_temp - yesterday_max_temp) < 10 {
                        notification_title = nil
                        notification_message = nil
                    }
                    else {*/
                        
                        if today_interval == TempInterval(nil, 0) {
                            
                            notification_message = "Stay inside, it's cold! "
                            
                        }
                        else if today_interval == TempInterval(1, 32) {
                            
                            notification_message = "Bundle up! "
                            
                            switch precip {
                            case "rain", "hail":
                                notification_message!.append("Get an umbrella. ")
                            case "snow", "sleet":
                                notification_message!.append("Drive safely. ")
                            default:
                                break
                            }
                            
                        }
                        else if today_interval == TempInterval(33, 50) {
                            
                            notification_message = ""
                            
                            if precip == "rain" || precip == "hail" {
                                notification_message = "Put on a raincoat. "
                            }
                            else {
                                notification_message = "Put on a coat. "
                            }
                            
                        }
                        else if today_interval == TempInterval(51, 70) {
                            
                            notification_message = ""
                            
                            if precip == "rain" {
                                notification_message = "Put on a raincoat. "
                            }
                            else {
                                notification_message = "Put on a sweater. "
                            }
                            
                        }
                        else if today_interval == TempInterval(71, 90) {
                            
                            notification_message = ""
                            
                            if precip == "rain" || precip == "hail" {
                                notification_message = "Put on a raincoat. "
                            }
                            else {
                                notification_message = "Enjoy the nice weather! "
                            }
                            
                        }
                        else if today_interval == TempInterval(91, nil) {
                            
                            notification_message = "It's burning outside 🔥🔥🔥"
                            
                            if precip == "rain" || precip == "hail" {
                                notification_message!.append("Also, grab an umbrella. ")
                            }
                            
                        }
                    notification_message!.append(summary)
                
                /*
                        
                    }
                }*/
                
                completion(notification_title, notification_message)
                
            })
        })
        
    }
    
    struct TempInterval {
        var min: Int?
        var max: Int?
        init(_ min: Int?, _ max: Int?) {
            self.min = min
            self.max = max
        }
        
        static func ==(left: TempInterval, right: TempInterval) -> Bool {
            return (left.min == right.min) && (left.max == right.max)
        }
        
        static func getInterval(of num: Int) -> TempInterval {
            
            switch num {
            case Int.min..<1:
                return TempInterval(nil, 0)
            case 1..<33:
                return TempInterval(1, 32)
            case 33..<51:
                return TempInterval(33, 50)
            case 51..<71:
                return TempInterval(51, 70)
            case 71..<91:
                return TempInterval(71, 90)
            case 91..<Int.max:
                return TempInterval(91, nil)
            default:
                return TempInterval(nil, nil)
            }
            
        }
    }
    
    /// Set up the local notification for everyday
    /// - parameter hour: The hour in 24 of the day to trigger the notification
    class func setUpLocalNotification(hour: Int, minute: Int, title: String, message: String) {
        
        // have to use NSCalendar for the components
        let calendar = NSCalendar(identifier: .gregorian)!;
        
        var dateFire = Date()
        
        // if today's date is passed, use tomorrow
        var fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire)
        
        if (fireComponents.hour! > hour
            || (fireComponents.hour == hour && fireComponents.minute! >= minute) ) {
            
            dateFire = dateFire.addingTimeInterval(86400)  // Use tomorrow's date
            fireComponents = calendar.components( [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.hour, NSCalendar.Unit.minute], from:dateFire);
        }
        
        // set up the time
        fireComponents.hour = hour
        fireComponents.minute = minute
        
        // schedule local notification
        dateFire = calendar.date(from: fireComponents)!
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = dateFire
        localNotification.alertTitle = title
        localNotification.alertBody = message
        localNotification.repeatInterval = NSCalendar.Unit.day
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        UIApplication.shared.scheduleLocalNotification(localNotification);
        
    }
    
}

// UIViewController overloads

extension WeatherController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
                
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

// location

extension WeatherController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc_value = manager.location!.coordinate
        WeatherController.current_location = loc_value
        DispatchQueue.main.async {
            self.initAppearence()
            self.location_manager.stopUpdatingLocation()
            self.location_manager.startMonitoringSignificantLocationChanges()
        }
    }
    
}

extension WeatherController: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.initialY = BottomBar.bottomBarHeight
        animator.transitionType = .Present
        return animator
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = MiniToLargeViewAnimator()
        animator.initialY = BottomBar.bottomBarHeight
        animator.transitionType = .Dismiss
        return animator
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard !disableInteractivePlayerTransitioning else { return nil }
        return presentInteractor
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard !disableInteractivePlayerTransitioning else { return nil }
        return dismissInteractor
    }
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return self[Range(start ..< end)]
    }
}


