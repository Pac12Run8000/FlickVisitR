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
        
        // MARK: Add PinAnnotation to shared array: PinAnnotationArray
        addPinAnnotationToSharedArray(pinAnnotation: pinAnnotation)
        
        // MARK: Changes Managed object context are being saved 

        saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext) { (success) in
            if (success) {
                self.mapView.addAnnotation(annotation)
            }
        }
        
        
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
        
        // MARK: With the new updates to xCode this functionality is depricated
//        findLocationOutlet.isEnabled = false
        
        mapView.delegate = self
        gestureRecognizerFunctionality()
        // MARK: As the name states, this function sets up retrieveing the coordinates based on userlocation.
        getCoordinatesBasedOnUsersLocation()
        
        // MARK: Populate the variable pinAnnotationArray:[PinAnnotation] in CoreDataStack
        // MARK: Populates the Map with PinAnnotations
        retrievePinAnnotationsFromCoreDataAndAddToMapView()
        
        // MARK: This is for the batch deletion of PinAnnotation
//        batchDeletePinAnnotation()
        
        // MARK: This is for batch deletion of PinImage
//        batchDeletePinImage()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        batchDeletePinAnnotationFromCoreData { (success) in
            if success! {
                self.removeAllPinAnnotations()
                self.removeAllPins()
            }
        }
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
                saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext) { (success) in
                    if (success) {
                        // MARK: adds the annotation to the pinAnnotationArray
                        self.addPinAnnotationToSharedArray(pinAnnotation: addAnnotation)
                        // MARK: adds annotation to mapView
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func removeAllPins() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}
// MARK: Handle CoreDataStack.sharedInstance().pinAnnotationArray functionality
extension MainMapViewController {
    
    func removeAllPinAnnotations() {
        CoreDataStack.sharedInstance().pinAnnotationArray.removeAll()
    }
    
    // MARK: Gets the index of the item from the array and then deletes it.
    func deletePinAnnotationFromPinAnnotationArray(pin:PinAnnotation?) {
        let index = CoreDataStack.sharedInstance().pinAnnotationArray.index(where: { (item) -> Bool in
            item == pin
        })
        if let index = index {
            CoreDataStack.sharedInstance().pinAnnotationArray.remove(at: index)
        }
    }
    
    func addPinAnnotationToSharedArray(pinAnnotation:PinAnnotation) {
        CoreDataStack.sharedInstance().pinAnnotationArray.insert(pinAnnotation, at: 0)
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
                // MARK: Gets the MKAnnotation from the map, does a fetch on CoreData and returns the PinAnnotation
                getPinAnnotationFromMKAnnotation(annotation) { (success, pin) in
                    if (success)! {
                        // MARK: Deletes the pinAnnotation from the shared PinnAnnotationArray.
                        self.deletePinAnnotationFromPinAnnotationArray(pin: pin)
                    }
                }
                // MARK: Deletes PinAnnotation from CoreData
                deletePinAnnotationFromCoreData(annotation)
                
                // MARK: Deletes PinAnnotation from MapView
                self.mapView.removeAnnotation(annotation)
                
            } else if (!editButtonOn) {
                let controller = storyboard?.instantiateViewController(withIdentifier: "ImagesCollectionViewController") as! ImagesCollectionViewController
                controller.annotation = annotation
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}


// MARK: This is the functionality responsible for adding a pin based on the users current location
extension MainMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print("location:\(locations.count)")
        let userLocation = locations[0] as CLLocation
        locationManager.stopUpdatingLocation()
        let annotation = MKPointAnnotation()
        annotation.coordinate = userLocation.coordinate
//        print("location coordinates: long:\(annotation.coordinate.latitude), long:\(annotation.coordinate.longitude)")
        let addAnnotation = PinAnnotation(context: delegate.coreDataStack.viewContext)
        addAnnotation.lat = annotation.coordinate.latitude
        addAnnotation.long = annotation.coordinate.longitude
        saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext) { (success) in
            if (success) {
                self.mapView.addAnnotation(annotation)
                self.addPinAnnotationToSharedArray(pinAnnotation: addAnnotation)
            }
        }
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
    
    
    func batchDeletePinAnnotationFromCoreData(completionHandler:@escaping (_ success:Bool?) -> ()) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try delegate.coreDataStack.viewContext.execute(request)
            completionHandler(true)
        } catch {
            print("error:\(error.localizedDescription)")
            completionHandler(false)
        }
    }
    
    func batchDeletePinImage(completionHandler: @escaping (_ sucess:Bool?) -> ()) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "PinImage")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try delegate.coreDataStack.viewContext.execute(request)
            completionHandler(true)
        } catch {
            print("error:\(error.localizedDescription)")
            completionHandler(false)
        }
    }
}

// MARK: Handles CoreData processing - Saves, Deletes and Retrieves CoreData information.
extension MainMapViewController {
    
    func getPinAnnotationFromMKAnnotation(_ annotation:MKAnnotation, completion:@escaping(_ success:Bool?,_ pin:PinAnnotation?) -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) as? [PinAnnotation] {
//            print("PinAnnotation:lat:\(results?.first?.lat), long:\(results?.first?.long)")
            completion(true, results?.first)
        }
        completion(false, nil)
//        print("lat:\(annotation.coordinate.latitude), long:\(annotation.coordinate.longitude)")
    }
    
    func deletePinAnnotationFromCoreData(_ annotation:MKAnnotation) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) {
            for result in results {
                delegate.coreDataStack.viewContext.delete(result as! NSManagedObject)
            }
            // MARK: The functionality saves the NSManagedObjectContext
            saveChangesToManagedObjectContext(context: delegate.coreDataStack.viewContext) { (success) in
                if (success) {
                    print("Deletion of items from the NSManagedObjectContext was successful.")
                }
            }
        }
    }
    
    
    func retrievePinAnnotationsFromCoreDataAndAddToMapView() {
        
        let fetchRequest:NSFetchRequest<PinAnnotation> = PinAnnotation.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDesc]
        // MARK: Array data is saved to a Singleton
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) {
            CoreDataStack.sharedInstance().pinAnnotationArray = results
            
            for result in CoreDataStack.sharedInstance().pinAnnotationArray {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = result.lat
                annotation.coordinate.longitude = result.long
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func saveChangesToManagedObjectContext(context:NSManagedObjectContext, completion:@escaping (_ success:Bool) -> ()) {
        do {
            try context.save()
            completion(true)
        } catch {
            print("error:\(error.localizedDescription)")
            completion(false)
        }
    }
}




