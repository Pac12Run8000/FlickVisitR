//
//  LocationListViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class LocationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pinArray = CoreDataStack.sharedInstance().pinAnnotationArray
        let pin = pinArray[(indexPath as NSIndexPath).row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MapDetailViewController") as! MapDetailViewController
        controller.coordinates = pin
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataStack.sharedInstance().pinAnnotationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let item = CoreDataStack.sharedInstance().pinAnnotationArray[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = "lat:\(item.lat):, long:\(item.long)"
        if let creationDate = item.creationDate {
            cell?.detailTextLabel?.text = dateFormatter.string(from: creationDate)
        }
        return cell!
    }
}


