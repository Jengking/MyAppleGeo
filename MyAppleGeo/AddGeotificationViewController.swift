//
//  AddGeotificationViewController.swift
//  MyAppleGeo
//
//  Created by Fadzley Hud on 31/05/2022.
//

import UIKit
import MapKit

protocol AddGeotificationsViewControllerDelegate: AnyObject {
    func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddGeotification geotification: Geotification)
}

class AddGeotificationViewController: UITableViewController {
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var zoomButton: UIBarButtonItem!
    @IBOutlet weak var eventTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: AddGeotificationsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [addButton, zoomButton]
        addButton.isEnabled = false
    }
    
    @IBAction func textFieldEditingChanged(sender: UITextField) {
        let radiusSet = !(radiusTextField.text?.isEmpty ?? true)
        let noteSet = !(noteTextField.text?.isEmpty ?? true)
        addButton.isEnabled = radiusSet && noteSet
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onAdd(sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        let radius = Double(radiusTextField.text ?? "") ?? 0
        let identifier = NSUUID().uuidString
        let note = noteTextField.text ?? ""
        let eventType: Geotification.EventType = (eventTypeSegmentedControl.selectedSegmentIndex == 0) ? .onEntry : .onExit
        let geotification = Geotification(coordinate: coordinate, radius: radius, identifier: identifier, note: note, eventType: eventType)
        delegate?.addGeotificationViewController(self, didAddGeotification: geotification)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onZoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToLocation(mapView.userLocation.location)
    }
}
