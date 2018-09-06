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
        for (key, val) in params {
            print("key:\(key), val:\(val)")
        }
    }
}

extension FlickrAPIClient {
    
    class func sharedInstance() -> FlickrAPIClient {
        struct Singleton {
            static var sharedinstance = FlickrAPIClient()
        }
        return Singleton.sharedinstance
    }
    
//    class func sharedInstance() -> FlickrAPIClient {
//        struct Singleton {
//            static var sharedInstance = FlickrAPIClient()
//        }
//        return Singleton.sharedInstance
//    }
}


// MARK: URLSession configuration
extension FlickrAPIClient {
    
    // MARK:function used to configure the URL Session
    func setDefaultTimeoutForConfiguration() -> URLSession {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 15.0
        sessionConfig.timeoutIntervalForResource = 15.0
        
        return URLSession(configuration: sessionConfig)
        
    }

}