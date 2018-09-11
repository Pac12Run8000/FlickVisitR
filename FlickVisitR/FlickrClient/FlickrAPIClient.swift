//
//  FlickrAPIClient.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 9/4/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation

class FlickrAPIClient: NSObject {
   
    var session = URLSession.shared
    
    func taskForGetPhotos(_ params:[String:AnyObject], completionHandlerForTask:@escaping (_ data:Data?,_ error:Error?) -> ()) {

        let url = buildURLFromParameters(params)
        let urlRequest = URLRequest(url: url)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            if (error != nil) {
                print("There was an error:\(String(describing: error?.localizedDescription))")
                completionHandlerForTask(nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your statuscode was out of range.")
                completionHandlerForTask(nil, nil)
                return
            }
            
            guard let data = data else {
                print("No data was returned")
                completionHandlerForTask(nil, nil)
                return
            }
            completionHandlerForTask(data, nil)
        }
        task.resume()
    }
}

// MARK: Creates the first part of the URL used in the API call
extension FlickrAPIClient {
    
    func buildURLFromParameters(_ parameters:[String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrAPIClient.Constants.Flickr.APIScheme
        components.host = FlickrAPIClient.Constants.Flickr.APIHost
        components.path = FlickrAPIClient.Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(queryItem)
        }
        return components.url!
    }
}


// MARK: This is the singleton functionality
extension FlickrAPIClient {
    
    class func sharedInstance() -> FlickrAPIClient {
        struct Singleton {
            static var sharedinstance = FlickrAPIClient()
        }
        return Singleton.sharedinstance
    }
}


// MARK: URLSession configuration
extension FlickrAPIClient {
    
    // MARK:function used to configure the URL Session
    func setDefaultTimeoutForConfiguration() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        
        return URLSession(configuration: sessionConfig)
    }
}
