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
