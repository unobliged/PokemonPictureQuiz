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
    
    @IBOutlet weak var choice1: UIImageView!
    @IBOutlet weak var choice2: UIImageView!
    @IBOutlet weak var choice3: UIImageView!
    @IBOutlet weak var choice4: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    var choiceImageViews = [UIImageView]()

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
        choiceImageViews = [choice1, choice2, choice3, choice4]
        for imageView in choiceImageViews {
            imageView.layer.borderColor = UIColor.blackColor().CGColor
            imageView.layer.borderWidth = 1
        }
        fetchedResultsController.delegate = self
        
        self.generateQuiz()
    }
    
    func generateQuiz() {
        var newQuiz = PokeQuiz()
        
        for (index, choice) in enumerate(newQuiz.choices) {
            PokeAPIClient.sharedInstance().getPokemon(choice) { (response) in
                if let name = response["name"] as? String, url = response["imageURL"] as? String {
                    PokeAPIClient.sharedInstance().savePokemon(choice, name: name, imageURL: url) { (pokemon) in
                        println(pokemon.image)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.choiceImageViews[index].image = pokemon.image
                        }
                    }
                }
            }
        }
    }

}
