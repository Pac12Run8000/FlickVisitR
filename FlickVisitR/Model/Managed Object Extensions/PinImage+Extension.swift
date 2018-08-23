//
//  PinImage+Extension.swift
//  FlickVisitR
//
//  Created by Michelle Grover on 8/22/18.
//  Copyright © 2018 Norbert Grover. All rights reserved.
//

import Foundation
import CoreData

extension PinImage {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
