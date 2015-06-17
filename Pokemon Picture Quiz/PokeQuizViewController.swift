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

    override func viewDidLoad() {
        super.viewDidLoad()
        PokeAPIClient.sharedInstance().getPokemon(700) { (response) in
            println(response)
        }
    }

}
