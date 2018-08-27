//
//  LocationListViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

class LocationListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for item in CoreDataStack.sharedInstance().pinAnnotationArray {
            print("item lat:\(item.lat), long:\(item.long)")
        }
    }

    

}
