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

    @NSManaged var id: Int
    @NSManaged var imageURL: String
    @NSManaged var imagePath: String
    @NSManaged var name: String
    @NSManaged var hp: Int
    @NSManaged var attack: Int
    @NSManaged var defense: Int
    @NSManaged var spatk: Int
    @NSManaged var spdef: Int
    @NSManaged var speed: Int
    @NSManaged var abilities: String
    @NSManaged var types: String
    @NSManaged var evolutions: String
    
    var image: UIImage? {
        get {
            return PokeAPIClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            PokeAPIClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }
    
}
