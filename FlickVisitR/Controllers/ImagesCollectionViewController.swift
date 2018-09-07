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
    
    // MARK: Array declarations to populate the collectionView
    var pinImages:[PinImage]!
    // MARK: Passing the annotation value from the MainMapViewController
    var annotation:MKAnnotation!
    
    // MARK: The array of perameters used to build a URLRequest
    var paramArray:[String:AnyObject]!
    
    
    // MARK: Delegate to access the NSManagedContext
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // Mark: Place holder data
    let collectionViewData = ["Oaktown 357","MC Hammer", "Too Short", "Tupac", "Ray Luv", "JT the Bigga Figga", "C-Bo", "Pizo", "Sweet LD", "Terrible T", "Cheri", "Starpoint", "Kieth Sweat", "Big Pun", "Big L", "LL Cool J", "Cool Moe Dee", "Positive K"]
    
    
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
        
        paramArray = getMethodParametersFromAnnotationCoordinates(annotation.coordinate)
        
        FlickrAPIClient.sharedInstance().getPhotos(paramArray, delegate.coreDataStack.viewContext) { (success, error, pinImages) in
            if (success)! {
                for pinImage in pinImages! {
                    print("title:\(pinImage.title), url:\(pinImage.url)")
                }
            }
        }
        
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewData.count
    }
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        print("Test!!!")
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
    
    
    func getMethodParametersFromAnnotationCoordinates(_ coordinate:CLLocationCoordinate2D) -> [String:AnyObject] {
        let parameters = [FlickrAPIClient.Constants.FlickrParameterKeys.APIKey : FlickrAPIClient.Constants.FlickrParameterValues.APIKey,
                          FlickrAPIClient.Constants.FlickrParameterKeys.BoundingBox : createBoundingBoxString(coordinates: coordinate),
                          FlickrAPIClient.Constants.FlickrParameterKeys.Method : FlickrAPIClient.Constants.FlickrParameterValues.SearchMethod,
                          FlickrAPIClient.Constants.FlickrParameterKeys.SafeSearch : FlickrAPIClient.Constants.FlickrParameterValues.UseSafeSearch,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Extras : FlickrAPIClient.Constants.FlickrParameterValues.MediumURL,
                          FlickrAPIClient.Constants.FlickrParameterKeys.NoJSONCallback : FlickrAPIClient.Constants.FlickrParameterValues.DisableJSONCallback,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Page : FlickrAPIClient.Constants.FlickrParameterValues.PageValue,
                          FlickrAPIClient.Constants.FlickrParameterKeys.Format : FlickrAPIClient.Constants.FlickrParameterValues.ResponseFormat,
                          FlickrAPIClient.Constants.FlickrParameterKeys.PerPage : FlickrAPIClient.Constants.FlickrParameterValues.PerPage
            ] as [String : Any]
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



