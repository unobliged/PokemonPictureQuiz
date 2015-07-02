//
//  PokeDetailViewController.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/29/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit

class PokeDetailViewController: UIViewController {

    @IBOutlet weak var pokemonImageView: UIImageView!
    @IBOutlet weak var pokemonNameLabel: UILabel!
    
    @IBOutlet weak var hpLabel: UIButton!
    @IBOutlet weak var spdLabel: UIButton!
    @IBOutlet weak var defLabel: UIButton!
    @IBOutlet weak var atkLabel: UIButton!
    @IBOutlet weak var spatkLabel: UIButton!
    @IBOutlet weak var spdefLabel: UIButton!
    @IBOutlet weak var abilitiesLabel: UIButton!
    @IBOutlet weak var evolutionsLabel: UIButton!
    @IBOutlet weak var typesLabel: UIButton!
    
    var selectedPokemon: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemonImageView.image = selectedPokemon.image
        pokemonNameLabel.text = selectedPokemon.name.capitalizedString
        
        if selectedPokemon.hp == 0 {
            getPokemonDetails()
        } else {
            displayPokemonDetails()
        }
    }
    
    func getPokemonDetails() {
        PokeAPIClient.sharedInstance().getPokemonStats(selectedPokemon.id) { (response) in
            println(response)
            if !self.checkForError(response) {
                PokeAPIClient.sharedInstance().savePokemonStats(self.selectedPokemon, stats: response) {
                    println(self.selectedPokemon)
                    self.displayPokemonDetails()
                }
            }
        }
    }
    
    func displayPokemonDetails() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.hpLabel.setTitle("\(self.selectedPokemon.hp)\nHP", forState: UIControlState.Normal)
            self.spdLabel.setTitle("\(self.selectedPokemon.speed)\nSPD", forState: UIControlState.Normal)
            self.atkLabel.setTitle("\(self.selectedPokemon.attack)\nATK", forState: UIControlState.Normal)
            self.defLabel.setTitle("\(self.selectedPokemon.defense)\nDEF", forState: UIControlState.Normal)
            self.spatkLabel.setTitle("\(self.selectedPokemon.spatk)\nSP.ATK", forState: UIControlState.Normal)
            self.spdefLabel.setTitle("\(self.selectedPokemon.spdef)\nSP.DEF", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func returnToCollection(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func checkForError(response: NSDictionary) -> Bool {
        if let status: AnyObject = response["status"], statusError: AnyObject = response["statusError"] {
            var alert = UIAlertController(title: "Error", message: "status: \(status), statusError: \(statusError)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.presentViewController(alert, animated: true, completion: nil)
            }
            
            return true
        } else {
            return false
        }
    }
}
