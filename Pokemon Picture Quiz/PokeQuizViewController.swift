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
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var choiceImageViews = [UIImageView]()
    var timer: NSTimer?
    var timeRemaining: Float = 0
    var score = 0
    
    var answerImageView: UIImageView?

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
        self.view.backgroundColor = UIColor(red: 71/255, green: 137/255, blue: 186/255, alpha: 1)
        choiceImageViews = [choice1, choice2, choice3, choice4]
        for imageView in choiceImageViews {
            imageView.backgroundColor = UIColor.whiteColor()
            imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            imageView.layer.borderWidth = 1
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapChoice:"))
        }
        progressView.progress = 0
        
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
                            self.answerImageView = self.choiceImageViews[index]
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
    
    func tapChoice(sender: UITapGestureRecognizer) {
        if sender.view == self.answerImageView {
            updateScore()
        } else {
            sender.view?.alpha = 0.5
        }
        stopTimer()
        revealAnswer()
    }
    
    func revealAnswer() {
        UIView.animateWithDuration(1, animations: {
            for civ in self.choiceImageViews {
                if civ == self.answerImageView {
                    civ.backgroundColor = UIColor.greenColor()
                    civ.backgroundColor = UIColor.whiteColor()
                } else {
                    civ.alpha = 1
                }
                civ.transform = CGAffineTransformMakeScale(1, 1)
            }
        }, completion: { (finished) in
            self.generateQuiz()
        })
    }
    
    func updateScore() {
        score++
        UIView.animateWithDuration(0.5, animations: {
            self.scoreLabel.transform = CGAffineTransformMakeScale(3, 3)
            self.scoreLabel.text = "Score: \(self.score)"
            self.scoreLabel.transform = CGAffineTransformMakeScale(1, 1)
        })
    }
    
    func startTimer() {
        timeRemaining = 15
        progressView.progress = 1
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        timeRemaining -= 0.01
        progressView.setProgress(timeRemaining / 15.0, animated: true)
        if timeRemaining == 0 {
            stopTimer()
        }
    }
    
    func stopTimer() {
        timer!.invalidate()
    }

}
