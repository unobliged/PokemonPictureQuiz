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
    var timeRemaining: Float = 60
    var score = 0
    var gameRunning = true
    
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
        progressView.progress = 1
        
        fetchedResultsController.delegate = self
        
        self.generateQuiz()
    }
    
    func generateQuiz() {
        gameRunning = true
        var newQuiz = PokeQuiz()
        var counter = newQuiz.choices.count
        for civ in choiceImageViews {
            civ.userInteractionEnabled = true
        }
        
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
        for civ in choiceImageViews {
            civ.userInteractionEnabled = false
        }
        
        if sender.view == self.answerImageView {
            updateScore()
        } else {
            sender.view?.alpha = 0.5
            subtractTime()
        }
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
            }
        }, completion: { (finished) in
            if self.timeRemaining > 0 && self.gameRunning {
                self.stopTimer()
                self.generateQuiz()
            }
        })
    }
    
    func updateScore() {
        score++
        UIView.animateWithDuration(0.5, animations: {
            self.scoreLabel.transform = CGAffineTransformMakeScale(3, 3)
            self.scoreLabel.text = "Score: \(self.score)"
            self.scoreLabel.transform = CGAffineTransformMakeScale(1, 1)
        })
        addTime()
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        timeRemaining -= 0.01
        progressView.setProgress(timeRemaining / 60.0, animated: true)
        if timeRemaining <= 0 {
            gameOver()
        }
    }
    
    // Tick() is called manually in add/subtract time to update progress view
    // revealAnswer stops the timer, preventing update until quiz reloaded
    func addTime() {
        if timeRemaining < 60 {
            timeRemaining += 10
            if timeRemaining > 60 { timeRemaining = 60 }
            tick()
        }
        revealAnswer()
    }
    
    func subtractTime() {
        if timeRemaining >= 10.5 { // 10.5 vs 10 to add some buffer for lag and tick call
            timeRemaining -= 10
            tick()
            self.revealAnswer()
        } else {
            timeRemaining = 0
            gameOver()
        }
    }
    
    func stopTimer() {
        timer!.invalidate()
    }
    
    func gameOver() {
        gameRunning = false
        revealAnswer()
        stopTimer()
        score = 0
        self.scoreLabel.text = "Score: \(self.score)"
        timeRemaining = 60
        self.progressView.progress = 1
        
        var alert = UIAlertController(title: "Out of time", message: "Game Over!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default) { (action) in
            self.generateQuiz()
        })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}
