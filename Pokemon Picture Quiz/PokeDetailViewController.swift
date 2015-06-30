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
    
    var selectedPokemon: Pokemon!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pokemonImageView.image = selectedPokemon.image
        pokemonNameLabel.text = selectedPokemon.name.capitalizedString
        
        getPokemonDetails()
    }
    
    func getPokemonDetails() {
        PokeAPIClient.sharedInstance().getPokemonStats(selectedPokemon.id) { (response) in
            println(response)
            PokeAPIClient.sharedInstance().savePokemonStats(self.selectedPokemon, stats: response) {
                println(self.selectedPokemon)
            }
        }
    }
    
    @IBAction func returnToCollection(sender: AnyObject) {
        dismissViewControllerAnimated(false, completion: nil)
    }
}
