//
//  CoreDataStack.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/22/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    let persistantContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    init(modelName:String) {
        persistantContainer = NSPersistentContainer(name: "Model")
    }
    
    func load(completion:(() -> ())? = nil) {
        persistantContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    
    
    
    var pinAnnotationArray = [PinAnnotation]()
    
    var pinImageArray = [PinImage]()
    
    class func sharedInstance() -> CoreDataStack {
        struct Singleton {
            static var sharedInstance = CoreDataStack(modelName: "Model")
        }
        return Singleton.sharedInstance
    }
}
