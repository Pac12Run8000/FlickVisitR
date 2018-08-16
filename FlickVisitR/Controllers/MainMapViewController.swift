//
//  MainMapViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class MainMapViewController: UIViewController {
    
    @IBOutlet weak var deleteButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var editButtonOn:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        gestureRecognizerFunctionality()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        editButtonOn = !editButtonOn
        
        deleteButtonOutlet.isEnabled = !editButtonOn
        editButtonOutlet.title = getEditButtonTitle(IsEditButtonOn: editButtonOn)
    }
    
    func getEditButtonTitle(IsEditButtonOn:Bool) -> String {
        return IsEditButtonOn ? "Done" : "Edit"
    }
}


// MARK: This is where the mapView pin drop functionality is located
extension MainMapViewController {
    
    // called from ViewDidLoad
    func gestureRecognizerFunctionality() {
        let mapPressed = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        mapPressed.minimumPressDuration = 1.0
        self.mapView.addGestureRecognizer(mapPressed)
    }
    
    @objc func addAnnotationOnLongPress(gesture:UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Dark Horse Fight Club"
            annotation.subtitle = "Training by invite only"
            
            
            self.mapView.addAnnotation(annotation)
        }
    }
}

// MARK: Functions that use the MKMapView protocol
extension MainMapViewController:MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false

            pinView?.pinTintColor = .blue
            pinView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView?.annotation = annotation
        }
        pinView?.animatesDrop = true
        return pinView
        
    }
    
    
}
