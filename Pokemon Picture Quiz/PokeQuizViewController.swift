//
//  PokeQuizViewController.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/16/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit
import CoreData

class PokeQuizViewController: UIViewController {
    //TODO: 

    @IBOutlet weak var choice1: UIImageView!
    @IBOutlet weak var choice2: UIImageView!
    @IBOutlet weak var choice3: UIImageView!
    @IBOutlet weak var choice4: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    var choiceImageViews = [UIImageView]()
    var timer: NSTimer?
    let maxTime: Float = 30
    var timeRemaining: Float = 0
    var score = 0
    var gameRunning = true
    
    var answerImageView: UIImageView?
    var counter: Int = 0
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        choiceImageViews = [choice1, choice2, choice3, choice4]
        for imageView in choiceImageViews {
            imageView.backgroundColor = UIColor.whiteColor()
            imageView.layer.borderColor = UIColor.lightGrayColor().CGColor
            imageView.layer.borderWidth = 1
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapChoice:"))
        }
        progressView.progress = 1
        timeRemaining = maxTime
        
        self.generateQuiz()
    }
    
    func fetchPokemon(id: Int) -> Pokemon? {
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let predicate = NSPredicate(format: "id = %d", id)
        fetchRequest.predicate = predicate
        
        let pokeFetch = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        pokeFetch.performFetch(nil)
        
        return pokeFetch.fetchedObjects?.first as? Pokemon
    }
    
    func generateQuiz() {
        gameRunning = true
        var newQuiz = PokeQuiz()
        counter = newQuiz.choices.count
        
        for (index, choice) in enumerate(newQuiz.choices) {
            if let pokemon = fetchPokemon(choice) {
                updatePokemonNameLabel(pokemon, answer: newQuiz.answer, index: index)
                updateChoiceImageViews(pokemon, index: index)
            } else {
                self.pokemonNameLabel.text = "Loading..."
                PokeAPIClient.sharedInstance().getPokemon(choice) { (response) in
                    if let name = response["name"] as? String, url = response["imageURL"] as? String {
                        PokeAPIClient.sharedInstance().savePokemon(choice, name: name, imageURL: url) { (pokemon) in
                            self.updatePokemonNameLabel(pokemon, answer: newQuiz.answer, index: index)
                            self.updateChoiceImageViews(pokemon, index: index)
                        }
                    } else {
                        println("problem with getting pokemon from API: \(response)")
                        // I tested with rapid spamming ~50 games; generating new quiz
                        // barely affected flow of game and was not noticeable
                        self.generateQuiz()
                    }
                }
            }
        }
    }
    
    func updatePokemonNameLabel(pokemon: Pokemon, answer: Int, index: Int) {
        if pokemon.id == answer {
            dispatch_async(dispatch_get_main_queue()) {
                self.pokemonNameLabel.text = pokemon.name.capitalizedString + "?"
            }
            self.answerImageView = self.choiceImageViews[index]
        }
    }
    
    func updateChoiceImageViews(pokemon: Pokemon, index: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            self.choiceImageViews[index].image = pokemon.image
            self.counter--
            
            if self.counter == 0 {
                self.startTimer()
                for civ in self.choiceImageViews {
                    civ.userInteractionEnabled = true
                }
            }
        }
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        if gameRunning && self.tabBarController?.selectedIndex == 0 {
            // Time Remaining effectively halves at score: 50
            // User testing (ss:~5) indicated boredom around 50-75 and higher failure with double tick speed
            timeRemaining -= (Float(score) / 50 + 1) * 0.01
            progressView.setProgress(timeRemaining / maxTime, animated: true)
            if timeRemaining <= 0 {
                gameOver()
            }
        }
    }
    
    func tapChoice(sender: UITapGestureRecognizer) {
        for civ in choiceImageViews {
            // Ensures no doubling of effects with rapid taps
            civ.userInteractionEnabled = false
        }
        
        if sender.view == self.answerImageView {
            updateScore()
        } else {
            sender.view?.alpha = 0.5
            subtractTime()
        }
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
    
    func addTime() {
        if timeRemaining < maxTime {
            timeRemaining += 10 // As effective time remaining decreases, this becomes a better benefit
            if timeRemaining > maxTime { timeRemaining = maxTime }
            progressView.setProgress(timeRemaining / maxTime, animated: true)
        }
        revealAnswer()
    }
    
    func subtractTime() {
        if timeRemaining > 1.1 { // 1.1 to account for minimum tick
            timeRemaining -= 1 // As effective time remaining decreases, this becomes a larger penalty
            progressView.setProgress(timeRemaining / maxTime, animated: true)
            if timeRemaining >= 0 {
                self.revealAnswer()
            }
        } else {
            timeRemaining = 0
            gameOver()
        }
    }
    
    func stopTimer() {
        timer!.invalidate()
    }
    
    func revealAnswer() {
        UIView.animateWithDuration(0.5, animations: {
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
    
    func gameOver() {
        gameRunning = false
        revealAnswer()
        stopTimer()
        timeRemaining = maxTime
        self.progressView.progress = 1
        
        var alert = UIAlertController(title: "Out of time", message: "Game Over!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.Default) { (action) in
            // Score is reset here so user can see their gameover score before starting new game
            self.score = 0
            self.scoreLabel.text = "Score: \(self.score)"
            self.generateQuiz()
        })
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

}
