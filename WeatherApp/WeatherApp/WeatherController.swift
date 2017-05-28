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
    
    static var current_location = CLLocation()
    let location_manager = CLLocationManager()
    static let key = "7d3b895abc519439bab335bae1d8f21e"
    var today_max_temp: Int!
    var yesterday_max_temp: Int!
    static var today_weather_data: Data?
    
    var disableInteractivePlayerTransitioning = false
    var bottomBar: BottomBar!
    var nextViewController: SettingsController!
    var presentInteractor: MiniToLargeViewInteractive!
    var dismissInteractor: MiniToLargeViewInteractive!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
        self.initAppearence()
        self.initLocation()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
        })
        

        // add subviews
        self.view.addSubview(current_temperature_label)
        self.view.addSubview(button)
        
        // enable contraints
        constrainCurrentTemperatureLabel()
        constrainButton()
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
        nextViewController.modalPresentationStyle = .fullScreen
        
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
    
    func action() {
        let content = UNMutableNotificationContent()
        content.title = "How many days are there in one year"
        content.subtitle = "Do you know?"
        content.body = "Do you really know?"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    /// views
    
    let current_temperature_label: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.font = label.font.withSize(100)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("button", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(action), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// constraints

    func constrainCurrentTemperatureLabel() {
        current_temperature_label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        current_temperature_label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
    
    func constrainButton() {
        button.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        button.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: button.intrinsicContentSize.width).isActive = true
        button.heightAnchor.constraint(equalToConstant: button.intrinsicContentSize.height).isActive = true
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
