//
//  ViewController.swift
//  MyAppleGeo
//
//  Created by Fadzley Hud on 31/05/2022.
//

import UIKit
import MapKit
import CoreLocation

enum PreferencesKeys: String {
    case savedItems
}

class GeotificationsViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var geotifications: [Geotification] = []
    lazy var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        loadAllGeotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    //MARK: Loading and saving functions
    func loadAllGeotifications(){
        geotifications.removeAll()
        let allGeotifications = Geotification.allGeotifications()
        allGeotifications.forEach{ add($0) }
    }
    
    //MARK: update functions
    func add(_ geotification: Geotification) {
        geotifications.append(geotification)
        mapView.addAnnotation(geotification)
        
    }
    
    //MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification){
        mapView.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    
}
//MARK: AddGeotificationViewControllerDelegate
extension GeotificationsViewController: AddGeotificationsViewControllerDelegate {
    func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddGeotification geotification: Geotification) {
        controller.dismiss(animated: true, completion: nil)
        
        geotification.clampRadius(maxRadius: locationManager.maximumRegionMonitoringDistance)
        add(geotification)
    }
}

//MARK: Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        mapView.showsUserLocation = (status == .authorizedAlways)
        if status != .authorizedAlways {
            let message = """
            Your Geofence is saved but will only be activated once you have grant permission to access device location.
            """
            showAlert(withTitle: "Warning", message: message)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        guard let region = region else {
            print("Monitoring failed for unknown region")
            return
        }
        print("Monitoring failed for region with identifier: \(region.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

//MARK: Map Delegate
extension GeotificationsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is Geotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(systemName: "trash.fill"), for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //delete geotification
        guard let geotification = view.annotation as? Geotification else { return }
        
    }
}

