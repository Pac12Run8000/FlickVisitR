//
//  MainMapViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/15/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MainMapViewController: UIViewController, AnnotationTypeViewControllerDelegate {
    
    //MARK: The delegate method adds the new annotation to the map.
    func annotationTypeViewController(_ controller: AnnotationTypeViewController, didFinishAdding item: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = item
        // MARK: Adding latitude and longitude to CoreData
        let pinAnnotation = PinAnnotation(context: delegate.coreDataStack.viewContext)
        pinAnnotation.lat = annotation.coordinate.latitude
        pinAnnotation.long = annotation.coordinate.longitude
        // MARK: Changes Managed object context are being saved 
        saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext)
        mapView.addAnnotation(annotation)
    }
    
    
    @IBOutlet weak var deleteButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var editButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var findLocationOutlet: UIBarButtonItem!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var editButtonOn:Bool = false
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        gestureRecognizerFunctionality()
        // MARK: As the name states, this function sets up retrieveing the coordinates based on userlocation.
        getCoordinatesBasedOnUsersLocation()
        
        // MARK: This is for the batch deletion of PinAnnotation
//        batchDeletePinAnnotation()
        
        // MARK: This is for batch deletion of PinImage
//        batchDeletePinImage()
        
        // MARK: Populate the variable pinAnnotationArray:[PinAnnotation] in CoreDataStack
        retrievePinAnnotationsFromCoreDataAndAddToMapView()
        
       
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let fetchRequest:NSFetchRequest<PinAnnotation> = PinAnnotation.fetchRequest()
//        let sortDesc = NSSortDescriptor(key: "creationDate", ascending: false)
//        fetchRequest.sortDescriptors = [sortDesc]
//
//        if let result = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) {
//            for item in result {
//                print("lat:\(item.lat),long:\(item.long), creationDate:\(String(describing: item.creationDate))")
//            }
//        }
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        editButtonOn = !editButtonOn
        findLocationOutlet.isEnabled = !editButtonOn
        deleteButtonOutlet.isEnabled = !editButtonOn
        editButtonOutlet.title = getEditButtonTitle(IsEditButtonOn: editButtonOn)
    }
    
    func getCoordinatesBasedOnUsersLocation() {
        locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    func getEditButtonTitle(IsEditButtonOn:Bool) -> String {
        return IsEditButtonOn ? "Done" : "Edit"
    }
    
    
    @IBAction func findLocationAction(_ sender: Any) {
        locationManager.startUpdatingLocation()
    }
    
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        batchDeletePinAnnotation()
        removeAllPins()
    }
}
// MARK: This is where we prepare for segue
extension MainMapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressToCoordinate" {
            let controller = segue.destination as! AnnotationTypeViewController
            controller.annotationTypeDelegate = self
            
        }
    }
}


// MARK: This is where the mapView pin drop and delete functionality is located
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
            // Edit state has to be off
            if !editButtonOn {
                let addAnnotation = PinAnnotation(context: delegate.coreDataStack.viewContext)
                addAnnotation.lat = annotation.coordinate.latitude
                addAnnotation.long = annotation.coordinate.longitude
                saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func removeAllPins() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if let annotation = view.annotation {
            if (editButtonOn) {
                deletePinAnnotationFromCoreData(annotation)
                self.mapView.removeAnnotation(annotation)
            }
        }
    }
}


// MARK: This is the functionality responsible for adding a pin based on the users current location
extension MainMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let annotation = MKPointAnnotation()
        annotation.coordinate = userLocation.coordinate
        mapView.addAnnotation(annotation)
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "user location access disabled", message: "The app needs access to your user location info", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let openAction = UIAlertAction(title: "Open settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
// MARK: These are the batch delete functions from CoreData
extension MainMapViewController {
    
    func batchDeletePinAnnotation() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try delegate.coreDataStack.viewContext.execute(request)
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }
    
    func batchDeletePinImage() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinImage")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try delegate.coreDataStack.viewContext.execute(request)
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }
}

// MARK: Handles CoreData processing
extension MainMapViewController {
    
    func deletePinAnnotationFromCoreData(_ annotation:MKAnnotation) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) {
            for result in results {
                delegate.coreDataStack.viewContext.delete(result as! NSManagedObject)
            }
            // MARK: The functionality saves the NSManagedObjectContext
            saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext)
        }
    }
    
    
    func retrievePinAnnotationsFromCoreDataAndAddToMapView() {
        let fetchRequest:NSFetchRequest<PinAnnotation> = PinAnnotation.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) {
            CoreDataStack.sharedInstance().pinAnnotationArray = results
            
            for result in results {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = result.lat
                annotation.coordinate.longitude = result.long
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func saveChangesToManagedObjectContext(context:NSManagedObjectContext) {
        do {
            try context.save()
            print("Saved!!!!!")
        } catch {
            print("error:\(error.localizedDescription)")
        }
    }
}
