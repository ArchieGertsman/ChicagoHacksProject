//
//  WeatherControllerViewController.swift
//  WeatherApp
//
//  Created by David Deborin on 5/27/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherController: UIViewController {
    
    static var current_location = CLLocation()
    let location_manager = CLLocationManager()
    let key = "7d3b895abc519439bab335bae1d8f21e"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAppearence()
        self.initLocation()

        // add subviews
        self.view.addSubview(current_temperature_label)
        
        // enable contraints
        constrainCurrentTemperatureLabel()
    }
    
    /// views
    
    let current_temperature_label: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = label.font.withSize(40)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// constraints

    func constrainCurrentTemperatureLabel() {
        current_temperature_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        current_temperature_label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
}
