//
//  AnnotationTypeViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

class AnnotationTypeViewController: UIViewController {
    
    @IBOutlet weak var getLocationButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationButton()
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    

}

// MARK: UI layout
extension AnnotationTypeViewController {
    func getLocationButton() {
        getLocationButtonOutlet.layer.cornerRadius = 4
        getLocationButtonOutlet.layer.masksToBounds = true
    }
}
