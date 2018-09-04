//
//  ImagesCollectionViewController.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/29/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit
import MapKit

class ImagesCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var refreshButtonOutlet: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Array declarations to populate the collectionView
    var pinImages:[PinImage]!
    // MARK: Passing the annotation value from the MainMapViewController
    var annotation:MKAnnotation!
    
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
        
        print("lat:\(annotation.coordinate.latitude), long:\(annotation.coordinate.longitude)")
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



