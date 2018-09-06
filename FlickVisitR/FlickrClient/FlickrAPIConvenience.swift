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
                return
            }
            
            let parsedResult:[String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                print("Couldn't parse data:\(data)")
                return
            }
            
            guard let stat = parsedResult["stat"] as? String, stat == "ok" else {
                print("Flickr returned an error.")
                return
            }
            
            guard let photos = parsedResult["photos"] as? [String:AnyObject] else {
                print("Cannot find key in parsedResult = photos")
                return
            }
            
//            guard let pages = photos["pages"] as? Int else {
//                print("Couldn't find the \'pages\' key.")
//                return
//            }


            guard let photoArray = photos["photo"] as? [[String:AnyObject]] else {
                print("Could not find the photo array.")
                return
            }
            
            for item in photoArray {
                if let title = item["title"], let url = item["url_m"] {
                    print("title:\(title), url:\(url)")
                }
            }
            
            
           
        }
        
    }
    
}
