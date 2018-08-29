//
//  MapDetailViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/28/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit


class MapDetailViewController: UIViewController, MKMapViewDelegate {
    
    var coordinates = PinAnnotation()
    let annotation = MKPointAnnotation()
    

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setPinAndZoomToLocation(coordinates)
        
        
    }
}

extension MapDetailViewController {
    // MARK: Function gets the location and is zzomed in to wher the pin is.
    func setPinAndZoomToLocation(_ coordinates:PinAnnotation) {
        let span:MKCoordinateSpan = MKCoordinateSpanMake(1.0, 1.0)
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(coordinates.lat, coordinates.long)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
        
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
}
