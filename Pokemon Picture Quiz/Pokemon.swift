//
//  Pokemon.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/17/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Pokemon)

class Pokemon: NSManagedObject {

    @NSManaged var imageURL: String
    @NSManaged var imagePath: String
    @NSManaged var name: String
    
    var image: UIImage? {
        get {
            return PokeAPIClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            PokeAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
}
