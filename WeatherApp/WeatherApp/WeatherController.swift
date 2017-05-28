//
//  WeatherControllerViewController.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class WeatherController: UIViewController {
    
    static var current_location = CLLocationCoordinate2D()
    let location_manager = CLLocationManager()
    static let key = "7d3b895abc519439bab335bae1d8f21e"
    var today_max_temp: Int!
    var today_weather_data: [String:Any]?
    
    // bottom bar variables
    var disableInteractivePlayerTransitioning = false
    var bottomBar: BottomBar!
    var nextViewController: SettingsController!
    var presentInteractor: MiniToLargeViewInteractive!
    var dismissInteractor: MiniToLargeViewInteractive!
    
    var array: [String] = {
        var array = [String]()
        array.append("Make sure to use public transportaion when possible.")
        array.append("Remember to carpool.")
        array.append("Consider buying an electric vehicle.")
        array.append("Talk to your representatives about climate change.")
        return array
    }()
    
    
    // data
    var current_temperature: Double! {
        didSet {
            self.current_temperature_label.text = "\(Int(current_temperature!))°"
        }
    }
    var feels_like_temperature: Double! {
        didSet {
            self.feels_like_temperature_label.text = "feels like \(Int(feels_like_temperature!))°"
        }
    }
    var precipitation_chance: Double! {
        didSet {
            self.precipitation_chance_label.text = "Chance of Precipitation: \(Int(precipitation_chance!*100))%"
        }
    }
    var humidity: Double! {
        didSet {
            self.humidity_label.text = "Humidity: \(Int(humidity!*100))%"
        }
    }
    var wind_speed: Double! {
        didSet {
            self.wind_speed_label.text = "Wind Speed: \(Double(round(10*wind_speed!)/10)) \(SettingsController.measurement_system == .imperial ? "mi/h" : "km/h")"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLocation()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in
            //
        })

        // add subviews
        self.view.addSubview(background_image_view)
        self.view.addSubview(current_temperature_label)
        self.view.addSubview(feels_like_temperature_label)
        self.view.addSubview(separator1)
        self.view.addSubview(weather_icon_view)
        self.view.addSubview(weather_icon_label)
        self.view.addSubview(separator2)
        self.view.addSubview(precipitation_chance_label)
        self.view.addSubview(humidity_label)
        self.view.addSubview(wind_speed_label)
        self.prepareView()
        
        // enable contraints
        constrainCurrentTemperatureLabel()
        constrainFeelsLikeTemperatureLabel()
        constrainSeparator1()
        constrainWeatherIcon()
        constrainWeatherIconLabel()
        constrainSeparator2()
        constrainPrecipitationChangeLabel()
        constrainHumidityLabel()
        constrainWindSpeedLabel()
        
        // self.initAppearence()
    }
    
    /// views
    
    static let transparent = UIColor(red: 1, green: 1, blue: 1, alpha: 0.75)
    
    // background image
    lazy var background_image_view: UIImageView = {
        let image_view = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        //image_view.image = #imageLiteral(resourceName: "Gradient_Day")
        image_view.backgroundColor = .white
        return image_view
    }()
    
    // temp label
    let current_temperature_label: UILabel = {
        let label = UILabel()
        //label.text = "84°"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 100)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // feels like
    let feels_like_temperature_label: UILabel = {
        let label = UILabel()
        //label.text = "feels like 80°"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // first separator view
    let separator1: UIView = {
        let view = UIView()
        view.backgroundColor = WeatherController.transparent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // weather icon
    let weather_icon_view: UIImageView = {
        let image_view = UIImageView()
        image_view.contentMode = .scaleAspectFill
        //image_view.image = #imageLiteral(resourceName: "Sun")
        image_view.translatesAutoresizingMaskIntoConstraints = false
        return image_view
    }()
    
    // weather icon label
    let weather_icon_label: UILabel = {
        let label = UILabel()
        //label.text = "Sunny"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // second separator view
    let separator2: UIView = {
        let view = UIView()
        view.backgroundColor = WeatherController.transparent
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // precipitation probability
    let precipitation_chance_label: UILabel = {
        let label = UILabel()
        //label.text = "Chance of Precipitation: 10%"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // humidity
    let humidity_label: UILabel = {
        let label = UILabel()
        //label.text = "Humidity: 40%"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // wind speed
    let wind_speed_label: UILabel = {
        let label = UILabel()
        //label.text = "Wind Speed: 6 mph"
        label.textColor = WeatherController.transparent
        label.font = UIFont(name: "SFUIDisplay-Thin", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// constraints

    func constrainCurrentTemperatureLabel() {
        current_temperature_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        current_temperature_label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -140).isActive = true
    }
    
    func constrainFeelsLikeTemperatureLabel() {
        feels_like_temperature_label.centerXAnchor.constraint(equalTo: current_temperature_label.centerXAnchor).isActive = true
        feels_like_temperature_label.topAnchor.constraint(equalTo: current_temperature_label.bottomAnchor, constant: 0).isActive = true
    }
    
    func constrainSeparator1() {
        separator1.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        separator1.topAnchor.constraint(equalTo: feels_like_temperature_label.bottomAnchor, constant: 15).isActive = true
        separator1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator1.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -60).isActive = true
    }
    
    func constrainWeatherIcon() {
        weather_icon_view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        weather_icon_view.topAnchor.constraint(equalTo: separator1.bottomAnchor, constant: 15).isActive = true
        weather_icon_view.widthAnchor.constraint(equalToConstant: 40).isActive = true
        weather_icon_view.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    func constrainWeatherIconLabel() {
        weather_icon_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        weather_icon_label.topAnchor.constraint(equalTo: weather_icon_view.bottomAnchor, constant: 5).isActive = true
    }
    
    func constrainSeparator2() {
        separator2.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        separator2.topAnchor.constraint(equalTo: weather_icon_label.bottomAnchor, constant: 10).isActive = true
        separator2.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        separator2.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -60).isActive = true
    }
    
    func constrainPrecipitationChangeLabel() {
        precipitation_chance_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        precipitation_chance_label.topAnchor.constraint(equalTo: separator2.bottomAnchor, constant: 10).isActive = true
    }
    
    func constrainHumidityLabel() {
        humidity_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        humidity_label.topAnchor.constraint(equalTo: precipitation_chance_label.bottomAnchor, constant: 5).isActive = true
    }
    
    func constrainWindSpeedLabel() {
        wind_speed_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        wind_speed_label.topAnchor.constraint(equalTo: humidity_label.bottomAnchor, constant: 5).isActive = true
    }
    
}


