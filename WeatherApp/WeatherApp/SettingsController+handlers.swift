//
//  SettingsController+handlers.swift
//  WeatherApp
//
//  Created by David Deborin on 5/28/17.
//  Copyright © 2017 Team Blue. All rights reserved.
//

import Foundation
import GooglePlaces

extension SettingsController {
    
    enum MeasurementSystem {
        case imperial
        case metric
    }
    
    func buttonTapped() {
        rootViewController?.disableInteractivePlayerTransitioning = true
        self.dismiss(animated: true) { [unowned self] in
            self.rootViewController?.disableInteractivePlayerTransitioning = false
        }
    }
    
    func switchIsChanged(_ mySwitch: UISwitch) {
        if mySwitch.isOn {
            SettingsController.measurement_system = .metric
            self.rootViewController?.configure(withMeasurementSystem: .metric)
        } else {
            SettingsController.measurement_system = .imperial
            self.rootViewController?.configure(withMeasurementSystem: .imperial)
        }
    }
    
    func chooseLocation() {
        let autocomplete_controller = GMSAutocompleteViewController()
        autocomplete_controller.delegate = self
        self.present(autocomplete_controller, animated: true, completion: nil)
    }
    
}


extension SettingsController: GMSAutocompleteViewControllerDelegate {
    // Google Places Autocompletion
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        WeatherController.current_location = place.coordinate
        self.rootViewController?.initAppearence()
        self.dismiss(animated: true, completion: nil) // dismiss after select place
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
