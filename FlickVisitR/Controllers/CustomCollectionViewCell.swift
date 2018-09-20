//
//  CustomCollectionViewCell.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/29/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
   
    @IBOutlet weak var activityIndicatorOutlet: UIActivityIndicatorView!
    
    var imageData:Data? {
        didSet {
            self.imageView.image = UIImage(data: imageData!)
        }
    }
    

    

    
    
}
