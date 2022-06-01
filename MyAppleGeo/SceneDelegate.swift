//
//  SceneDelegate.swift
//  MyAppleGeo
//
//  Created by Fadzley Hud on 31/05/2022.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
}

//MARK: - Location Manager Delegate
extension SceneDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
    }
    
    func handleEvent(for region: CLRegion) {
        if UIApplication.shared.applicationState == .active {
            guard let message = note(from: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            guard let body = note(from: region.identifier) else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body
            notificationContent.sound = .default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change", content: notificationContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error =  error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func note(from identifier: String) -> String? {
        let geotifications = Geotification.allGeotifications()
        let matched = geotifications.first { $0.identifier == identifier }
        return matched?.note
    }
}

