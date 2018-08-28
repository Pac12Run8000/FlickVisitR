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



//protocol LocationListViewControllerDelegate:class {
//    func locationListViewControllerCoords(_ controller:LocationListViewController, _ lat:Double, _ long:Double)
//}

class LocationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
//    weak var locationListDelegate:LocationListViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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

extension LocationListViewController {
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationDetail" {
            let controller = segue.destination as! MapDetailViewController
            
        }
    }
    

}
