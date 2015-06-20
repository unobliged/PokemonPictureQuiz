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
    @IBOutlet weak var timerLabel: UILabel!
    
    var choiceImageViews = [UIImageView]()
    var timer = NSTimer()
    var timeRemaining = 0

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
        var counter = newQuiz.choices.count
        
        for (index, choice) in enumerate(newQuiz.choices) {
            PokeAPIClient.sharedInstance().getPokemon(choice) { (response) in
                if let name = response["name"] as? String, url = response["imageURL"] as? String {
                    PokeAPIClient.sharedInstance().savePokemon(choice, name: name, imageURL: url) { (pokemon) in
                        if pokemon.id == newQuiz.answer {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.pokemonNameLabel.text = pokemon.name.capitalizedString + "?"
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.choiceImageViews[index].image = pokemon.image
                            counter--
                            if counter == 0 {
                                self.startTimer()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startTimer() {
        timeRemaining = 15
        timerLabel.text = String(format: "%02d:%02d", 0, timeRemaining)
        timerLabel.text = "00:\(timeRemaining)"
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("tick:"), userInfo: nil, repeats: true)
    }
    
    func tick(timer: NSTimer) {
        timeRemaining--
        timerLabel.text = String(format: "%02d:%02d", 0, timeRemaining)
        if timeRemaining == 0 {
            stopTimer()
        }
    }
    
    func stopTimer() {
        timer.invalidate()
    }

}
