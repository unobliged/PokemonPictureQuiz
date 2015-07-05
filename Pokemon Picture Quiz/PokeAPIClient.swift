//
//  PokeAPI Client.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/17/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PokeAPIClient {
    // Reminder: PokeAPI currently only has 718 listings

    var session : NSURLSession
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    func getPokemon(id: Int, completionHandler: (response: NSDictionary) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://pokeapi.co/api/v1/sprite/\(id + 1)")!) // sprite id and pokedex id are offset by 1 in the API
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                println(error)
                completionHandler(response: ["status": "???", "statusError": "network error"])
                return
            }
            
            PokeAPIClient.parseJSONWithCompletionHandler(data, completionHandler: { (data, error) in
                if error != nil {
                    println(error)
                    completionHandler(response: ["status": "???", "statusError": "error parsing response"])
                    return
                }
        
                PokeAPIClient.parsePokeAPIResponse(data) { (response) in
                    completionHandler(response: response)
                }
            })
        }
        task.resume()
        
        return task
    }
    
    class func parsePokeAPIResponse(parsedJSON: AnyObject, completionHandler: (response: NSDictionary) -> Void) {
        if let image = parsedJSON["image"] as? String, pokemon = parsedJSON["pokemon"] as? NSDictionary {
            let imageURL = "http://pokeapi.co/" + image
            let name = pokemon["name"] as! String
            let response = ["name": name, "imageURL": imageURL]
            completionHandler(response: response)
        } else if let abilitiesList = parsedJSON["abilities"] as? [NSDictionary], typesList = parsedJSON["types"] as? [NSDictionary], evolutionsList = parsedJSON["evolutions"] as? [NSDictionary], hp = parsedJSON["hp"] as? Int, attack = parsedJSON["attack"] as? Int, defense = parsedJSON["defense"] as? Int, spatk = parsedJSON["sp_atk"] as? Int, spdef = parsedJSON["sp_def"] as? Int, speed = parsedJSON["speed"] as? Int {
            var abilities = ""
            for ability in abilitiesList {
                let tempAbility = ability["name"] as! String
                abilities += tempAbility + " "
            }
            
            var types = ""
            for type in typesList {
                let tempType = type["name"] as! String
                types += tempType + " "
            }
            
            var evolutions = ""
            for evolution in evolutionsList {
                let tempEvolution = evolution["to"] as! String
                evolutions += tempEvolution + " "
            }
            
            let response = ["abilities": abilities, "types": types, "evolutions": evolutions, "hp": hp, "attack": attack, "defense": defense, "spatk": spatk, "spdef": spdef, "speed": speed]
            completionHandler(response: response)
        } else {
            let response = ["status": "???", "statusError": "unexpected API response"]
            completionHandler(response: response)
        }
    }
    
    func savePokemon(id: Int, name: String, imageURL: String, completionHandler: ((pokemon: Pokemon) -> Void)) {
        var newPokemon = NSEntityDescription.insertNewObjectForEntityForName("Pokemon", inManagedObjectContext: sharedContext) as! Pokemon
        newPokemon.id = id
        newPokemon.name = name
        newPokemon.imageURL = imageURL
        let url = NSURL(string: imageURL)
        newPokemon.imagePath = url!.lastPathComponent!
        CoreDataStackManager.sharedInstance().saveContext()
      
        self.getPokemonImage(imageURL) { (response) in
            if let data = response {
                if let pokemonImage = UIImage(data: data) {
                    newPokemon.image = pokemonImage
                    completionHandler(pokemon: newPokemon)
                }
            }
        }
    }
    
    func savePokemonStats(pokemon: Pokemon, stats: NSDictionary, completionHandler: (() -> Void)) {
        pokemon.hp = stats["hp"] as! Int
        pokemon.attack = stats["attack"] as! Int
        pokemon.defense = stats["defense"] as! Int
        pokemon.spatk = stats["spatk"] as! Int
        pokemon.spdef = stats["spdef"] as! Int
        pokemon.speed = stats["speed"] as! Int
        pokemon.abilities = stats["abilities"] as! String
        pokemon.types = stats["types"] as! String
        pokemon.evolutions = stats["evolutions"] as! String
        CoreDataStackManager.sharedInstance().saveContext()
        completionHandler()
    }
    
    func getPokemonImage(imageURL: String, completionHandler: ((response: NSData?) -> Void)) -> NSURLSessionDataTask {
        let imageURL = NSURL(string: imageURL)
        let task = session.dataTaskWithURL(imageURL!) { (data, response, error) in
            if error != nil {
                completionHandler(response: nil)
                return
            }
            
            completionHandler(response: NSData(data: data))
        }
        task.resume()
        
        return task
    }
    
    func getPokemonStats(id: Int, completionHandler: (response: NSDictionary) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "http://pokeapi.co/api/v1/pokemon/\(id)")!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error != nil {
                println(error)
                completionHandler(response: ["status": "???", "statusError": "network error"])
                return
            }
    
            PokeAPIClient.parseJSONWithCompletionHandler(data, completionHandler: { (data, error) in
                if error != nil {
                    println(error)
                    completionHandler(response: ["status": "???", "statusError": "error parsing response"])
                    return
                }
        
                PokeAPIClient.parsePokeAPIResponse(data) { (response) in
                    completionHandler(response: response)
                }
            })
        }
        task.resume()
        
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    class func sharedInstance() -> PokeAPIClient {
        struct Singleton {
            static var sharedInstance = PokeAPIClient()
        }
        
        return Singleton.sharedInstance
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}