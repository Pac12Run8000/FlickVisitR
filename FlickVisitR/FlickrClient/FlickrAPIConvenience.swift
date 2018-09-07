//
//  FlickrAPIConvenience.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 9/4/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData

extension FlickrAPIClient {
    
    func getPhotos(_ params:[String:AnyObject], _ context:NSManagedObjectContext?, completionHandler: @escaping (_ success:Bool?, _ error:String?, _ photos:[PinImage]?) -> ()) {
        
        
        
        FlickrAPIClient.sharedInstance().taskForGetPhotos(params) { (data, error) in
            if (error != nil) {
                completionHandler(false, error?.localizedDescription, nil)
                return
            }
            
            guard let data = data else {
                print("An error occurred retrieving data.")
                completionHandler(false, nil, nil)
                return
            }
            
            let parsedResult:[String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Couldn't parse data:\(data)")
                completionHandler(false, nil, nil)
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                print("Flickr returned an error.")
                completionHandler(false, nil, nil)
                return
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("Cannot find key in parsedResult = photos")
                completionHandler(false, nil, nil)
                return
            }
            
//            guard let pages = photos["pages"] as? Int else {
//                print("Couldn't find the \'pages\' key.")
//                return
//            }


            guard let photoArray = photos["photo"] as? [[String:AnyObject]] else {
                print("Could not find the photo array.")
                completionHandler(false, nil, nil)
                return
            }
           
            var photoArrayToAppend = [PinImage]()
            DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                if photoArray.count == 0 {
                    completionHandler(false, nil, nil)
                } else {
                    for item in photoArray {
                        let pinImage = PinImage(context: context!)
                        pinImage.title = item["title"] as! String
                        pinImage.url = item["url_m"] as! String
                        pinImage.image = nil
                        
                        photoArrayToAppend.append(pinImage)
                        completionHandler(true, nil, photoArrayToAppend)
                    }
                }
            }
            
            
        }
    }
    
}
