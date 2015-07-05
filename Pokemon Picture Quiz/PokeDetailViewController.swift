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
        
        // Technically some pokemon have a default hp of 0
        // For most though, this is a quick check to see if it's in core data
        if selectedPokemon.hp == 0 {
            getPokemonDetails()
        } else {
            displayPokemonDetails()
        }
    }
    
    func getPokemonDetails() {
        PokeAPIClient.sharedInstance().getPokemonStats(selectedPokemon.id) { (response) in
            if !self.checkForError(response) {
                PokeAPIClient.sharedInstance().savePokemonStats(self.selectedPokemon, stats: response) {
                    self.displayPokemonDetails()
                }
            }
        }
    }
    
    func displayPokemonDetails() {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.hpLabel.setTitle("HP\n\(self.selectedPokemon.hp)", forState: UIControlState.Normal)
            self.spdLabel.setTitle("SPD\n\(self.selectedPokemon.speed)", forState: UIControlState.Normal)
            self.atkLabel.setTitle("ATK\n\(self.selectedPokemon.attack)", forState: UIControlState.Normal)
            self.defLabel.setTitle("DEF\n\(self.selectedPokemon.defense)", forState: UIControlState.Normal)
            self.spatkLabel.setTitle("SP.ATK\n\(self.selectedPokemon.spatk)", forState: UIControlState.Normal)
            self.spdefLabel.setTitle("SP.DEF\n\(self.selectedPokemon.spdef)", forState: UIControlState.Normal)
            self.abilitiesLabel.setTitle("Abilities:\n\(self.selectedPokemon.abilities)", forState: UIControlState.Normal)
            self.typesLabel.setTitle("Types:\n\(self.selectedPokemon.types)", forState: UIControlState.Normal)
            
            if self.selectedPokemon.evolutions == "" {
                self.evolutionsLabel.setTitle("Evolutions:\nNone", forState: UIControlState.Normal)
            } else {
                self.evolutionsLabel.setTitle("Evolutions:\n\(self.selectedPokemon.evolutions)", forState: UIControlState.Normal)
            }
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
