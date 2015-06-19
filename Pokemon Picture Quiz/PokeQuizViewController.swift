//
//  PokeQuizViewController.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/16/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit
import CoreData

class PokeQuizViewController: UIViewController, NSFetchedResultsControllerDelegate {

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        let num = 700
        PokeAPIClient.sharedInstance().getPokemon(num) { (response) in
            println(response)
            if let name = response["name"] as? String, url = response["imageURL"] as? String {
//                PokeAPIClient.sharedInstance().savePokemon(name, imageURL: url, completionHandler: nil)
                PokeAPIClient.sharedInstance().savePokemon(num, name: name, imageURL: url) {
                    self.fetchedResultsController.performFetch(nil)
                    println(self.fetchedResultsController.fetchedObjects)
                    let pokeTest = self.fetchedResultsController.fetchedObjects?.first as! Pokemon
                    if let newImage = pokeTest.image {
                        let test = UIImageView(image: newImage)
                        test.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2, 100, 100)
                        self.view.addSubview(test)
                    }
                }
            }
        }
    }

}
