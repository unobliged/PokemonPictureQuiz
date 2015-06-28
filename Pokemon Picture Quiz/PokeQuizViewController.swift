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
    
    func generateQuiz() {
        gameRunning = true
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
                            /* 
                                Counter == 0 ensures game only starts when everything
                                is ready. During testing I also found that click
                                spamming could lead to CoreData nil insertion due to
                                generating quiz too quickly
                            */
                            if counter == 0 {
                                self.startTimer()
                                for civ in self.choiceImageViews {
                                    civ.userInteractionEnabled = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        if gameRunning {
            timeRemaining -= 0.01
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
            timeRemaining += 10
            if timeRemaining > maxTime { timeRemaining = maxTime }
            progressView.setProgress(timeRemaining / maxTime, animated: true)
        }
        revealAnswer()
    }
    
    func subtractTime() {
        if timeRemaining > 10.1 { // 10.1 to account for minimum tick
            timeRemaining -= 10
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
        score = 0
        self.scoreLabel.text = "Score: \(self.score)"
        timeRemaining = maxTime
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
