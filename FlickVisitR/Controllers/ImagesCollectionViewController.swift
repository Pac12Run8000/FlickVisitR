//
//  ImagesCollectionViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/29/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ImagesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var refreshButtonOutlet: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    
    // MARK: Passing the annotation value from the MainMapViewController
    var annotation:MKAnnotation!
    
    
    
    // MARK: The array of perameters used to build a URLRequest
    var paramArray:[String:AnyObject]!
    
    
    // MARK: Delegate to access the NSManagedContext
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayoutSetUp()
        
        refreshButtonOutlet.layer.borderWidth = 3
        refreshButtonOutlet.layer.cornerRadius = 6
        refreshButtonOutlet.layer.masksToBounds = true
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Retrieve PinAnnotation from CoreData
        // MARK: You must have a specific PinAnnotation is order to search for pinImages that have a relationship to the current PinAnnotation
        getPinAnnotationFromMKAnnotation(annotation) { (success, pins) in
            
            if let pin = pins?.first {
            self.getPinImagesFromCoreData(pinAnnotation: pin, completionHandler: { (successForPinImages, pinImages) in
                if (successForPinImages) {
                    if (pinImages?.count == 0) {
                        print("Save pinImages")
                    } else {
                        print("Get pinImages")
                    }
                } else {
                    print("The attempt at getting pinImages failed.")
                }
            })
            }
        }
       
        
        
        
        // MARK: Takes the coordinate information from the MKAnnotation
        paramArray = getMethodParametersFromAnnotationCoordinates(annotation.coordinate)
        // MARK: This method populates the variable declared at the top "populateCollectionview" with Data from the API call
        populateArrayForCollectionView(paramArray: paramArray)
    }
    
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CoreDataStack.sharedInstance().pinImageArray = [PinImage]()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let itemForCollectionView = CoreDataStack.sharedInstance().pinImageArray[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        cell.pinImageObject = itemForCollectionView
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return CoreDataStack.sharedInstance().pinImageArray.count
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        // MARK: Generate a random number
        let randomPageString = generateRandomNumberAsString()
        // MARK: Get an array of parameters and make Page equal to a random number
        paramArray = getMethodParametersFromAnnotationCoordinates(annotation.coordinate, randomPageString)
        populateArrayForCollectionView(paramArray: paramArray)
    }
}

// MARK: This is the API call that populates the collectionView
extension ImagesCollectionViewController {
    
    func populateArrayForCollectionView(paramArray:[String:AnyObject]) {
        FlickrAPIClient.sharedInstance().getPhotos(paramArray, delegate.coreDataStack.viewContext) { (success, error, pinImages) in
            
            if (success)! {
                
                DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                    // MARK: Prevent a nil value that causes a fatal crash
                    if let pinImages = pinImages {
//                        self.arrayForCollectionView = pinImages
                        CoreDataStack.sharedInstance().pinImageArray = pinImages
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
                
            }
        }
    }
}

// MARK: Setup the flowlayout
extension ImagesCollectionViewController {
    
    func flowLayoutSetUp() {
        // You get the - 20 from the min spacing for cells in your size attributes for collectionView
//                let width = (view.frame.size.width - 20) / 3
//                let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
//                layout.itemSize = CGSize(width: width, height: width)
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
// MARK: Build an array of parameters that will eventually be used to create a querystring for the request
extension ImagesCollectionViewController {
    
    // MARK: The function can be called by either using 1 or 2 parameters
    // MARK: The parameter key of Page is 1 by default. Otherwise you can pass a string that represents any number. In this case the number is a random number between 1 and 20
    func getMethodParametersFromAnnotationCoordinates(_ coordinate:CLLocationCoordinate2D,_  randomStringForPage:String? = nil) -> [String:AnyObject] {
        var parameters = [FlickrAPIClient.Constants.FlickrParameterKeys.APIKey : FlickrAPIClient.Constants.FlickrParameterValues.APIKey,
                          FlickrAPIClient.Constants.FlickrParameterKeys.BoundingBox : createBoundingBoxString(coordinates: coordinate),
                          FlickrAPIClient.Constants.FlickrParameterKeys.Method : FlickrAPIClient.Constants.FlickrParameterValues.SearchMethod,
                          FlickrAPIClient.Constants.FlickrParameterKeys.SafeSearch : FlickrAPIClient.Constants.FlickrParameterValues.UseSafeSearch,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Extras : FlickrAPIClient.Constants.FlickrParameterValues.MediumURL,
                          FlickrAPIClient.Constants.FlickrParameterKeys.NoJSONCallback : FlickrAPIClient.Constants.FlickrParameterValues.DisableJSONCallback,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Page : FlickrAPIClient.Constants.FlickrParameterValues.PageValue,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Format : FlickrAPIClient.Constants.FlickrParameterValues.ResponseFormat,
                          FlickrAPIClient.Constants.FlickrParameterKeys.PerPage : FlickrAPIClient.Constants.FlickrParameterValues.PerPage
            ] as [String : Any]
        // MARK: This functionality passes a value for the page parameter in the API call otherwise the defualt value is "1"
        if let randomStringForPage = randomStringForPage {
            parameters["page"] = randomStringForPage
        }

        return parameters as [String : AnyObject]
    }
}



// MARK: This is the functionality for creating the bounding box
extension ImagesCollectionViewController {
    
    func createBoundingBoxString(coordinates: CLLocationCoordinate2D) -> String {
        if let latitude = coordinates.latitude as? Double, let longitude = coordinates.longitude as? Double {
            let minimumLong = max(longitude - FlickrAPIClient.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPIClient.Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - FlickrAPIClient.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPIClient.Constants.Flickr.SearchLatRange.0)
            let maximumLong = min(longitude + FlickrAPIClient.Constants.Flickr.SearchBBoxHalfWidth, FlickrAPIClient.Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + FlickrAPIClient.Constants.Flickr.SearchBBoxHalfHeight, FlickrAPIClient.Constants.Flickr.SearchLatRange.1)
            return "\(minimumLong),\(minimumLat),\(maximumLong),\(maximumLat)"
        }
        return "0,0,0,0"
    }
}

extension ImagesCollectionViewController {
    
    // MARK: Generate a random number
    func generateRandomNumberAsString() -> String {
        let randomPage = Int(arc4random_uniform(UInt32(20))) + 1
        return "\(randomPage)"
    }
    
}

// MARK: This is where the data interacts with CoreData
extension ImagesCollectionViewController {
    
    // MARK: get the pinAnnotation from the MKAnnotation
    func getPinAnnotationFromMKAnnotation(_ annotation:MKAnnotation, completion:@escaping(_ success:Bool?,_ pin:[PinAnnotation]?) -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinAnnotation")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let pred = NSPredicate(format: "lat = %lf AND long = %lf", annotation.coordinate.latitude, annotation.coordinate.longitude)
        fetchRequest.predicate = pred
        if let results = try? delegate.coreDataStack.viewContext.fetch(fetchRequest) as? [PinAnnotation] {
            completion(true, results)
        } else {
            completion(false, nil)
        }
    }
    
    // MARK: This is where you retrieve images from CoreData
    func getPinImagesFromCoreData(pinAnnotation:PinAnnotation, completionHandler: @escaping (_ success:Bool, _ pinImages:[PinImage]?) ->()) {
        
        var coreDataPinImages = [PinImage]()
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "PinImage")
        fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let pred = NSPredicate(format: "pinAnnotation = %@", pinAnnotation)
        fr.predicate = pred
        do {
            coreDataPinImages = try delegate.coreDataStack.viewContext.fetch(fr) as! [PinImage]
            completionHandler(true, coreDataPinImages)
        } catch {
            print("There was an error retrieving images from CoreData to display.")
            completionHandler(false, nil)
        }
    }
}



