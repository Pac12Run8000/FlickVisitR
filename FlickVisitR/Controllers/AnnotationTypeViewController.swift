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
        
        getLocationButtonOutlet.layer.cornerRadius = 4
        getLocationButtonOutlet.layer.masksToBounds = true
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    

}
