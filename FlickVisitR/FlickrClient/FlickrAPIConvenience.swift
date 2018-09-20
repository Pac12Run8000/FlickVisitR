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
            
            // MARK: This method takes the photoArray and uses the closure to return an array of PinImages with image data and not just a URL string
            self.getImageDataForPinImageArray(photoArray: photoArray, context: context, photoArrayCompletionHandler: { (pinImages) in
                
                completionHandler(true, nil, pinImages)
            })
        }
    }
    
}


extension FlickrAPIClient {
    
    
    func getImageDataForPinImageArray(photoArray:[[String:AnyObject]], context:NSManagedObjectContext?, photoArrayCompletionHandler: @escaping (_ pinImage:[PinImage]?) -> ()) {
        
        var photoArrayToAppend = [PinImage]()
        DispatchQueue.global(qos: .userInitiated).async { () -> Void in
            if photoArray.count == 0 {
                photoArrayCompletionHandler(nil)
            } else {
                for item in photoArray {
                    guard let _ = context else {
                        print("There was no context available.")
                        return
                    }
                   
                    let pinImage = PinImage(context: context!)
                    
                    guard let _ = pinImage as? PinImage else {
                        print("There was an error with the pinImage.")
                        return
                    }
                    

                    if let urlString = item["url_m"] as? String {
                        pinImage.title = item["title"] as? String
                        pinImage.url = urlString
//                        pinImage.image = imgData
                        pinImage.image = nil
                    }
                    
                    photoArrayToAppend.append(pinImage)
                    photoArrayCompletionHandler(photoArrayToAppend)
                }
            }
        }
        
    }
}

//MARK: Retrieve the image data
extension FlickrAPIClient {
    
    
    func getImageDataFromUrl(stringUrl:String, completionHandler:@escaping (_ data:Data?, _ error:String?) -> ()) {
        
        DispatchQueue.main.async {
            if let url = URL(string: stringUrl), let imgData = try? Data(contentsOf: url) {
                completionHandler(imgData, nil)
            } else {
                completionHandler(nil, "There was an error getting the image")
            }
        }
        
    }
    
}
