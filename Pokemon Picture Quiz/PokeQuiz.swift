//
//  PokeQuiz.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/19/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import Foundation

class PokeQuiz {
    var answer = Int(arc4random_uniform(718) + 1) // 718 is max accessible ID in PokeAPI
    var choices = Set<Int>()
    
    init() {
        self.generateChoices()
    }
    
    func generateChoices() {
        choices.insert(answer)
        while choices.count < 4 {
            let choice = Int(arc4random_uniform(718) + 1)
            choices.insert(choice)
        }
    }
    
}