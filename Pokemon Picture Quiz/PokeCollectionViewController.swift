//
//  PokeCollectionViewController.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/16/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit
import CoreData

let reuseIdentifier = "PokeCell"

class PokeCollectionViewController: UICollectionViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    var selectedPokemon: Pokemon?
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Pokemon")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView!.registerClass(PokeCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        fetchedResultsController.delegate = self
        fetchedResultsController.performFetch(nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchedResultsController.fetchedObjects!.isEmpty {
            return 1
        }
        
       return fetchedResultsController.fetchedObjects!.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PokeCollectionViewCell
        
        // Handles scenario where no images found
        if fetchedResultsController.fetchedObjects!.isEmpty {
            cell.label.text = "No Images"
            cell.pokeImageView.image = UIImage()
            return cell
        }
        
        let pokemon = fetchedResultsController.objectAtIndexPath(indexPath) as! Pokemon
        if pokemon.image != nil {
            cell.pokeImageView.image = pokemon.image
        } else {
            cell.label.text = "Loading..."
            PokeAPIClient.sharedInstance().getPokemonImage(pokemon.imageURL) { (response) in
                if let data = response {
                    if let pokeImage = UIImage(data: data) {
                        pokemon.image = pokeImage
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.label.text = ""
                            cell.pokeImageView.image = pokeImage
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PokeHeader", forIndexPath: indexPath) as! UICollectionReusableView
            
            let headerLabel = UILabel(frame: CGRectMake((header.frame.size.width - 230) / 2, 21, 230, 21))
            headerLabel.textAlignment = NSTextAlignment.Center
            if let pokemonCount = fetchedResultsController.fetchedObjects?.count {
                let headerLabelText = "Pokemon Collection: \(pokemonCount)/718"
                headerLabel.text = headerLabelText
            } else {
                headerLabel.text = "Pokemon Collection"
            }
            headerLabel.textColor = UIColor.whiteColor()
            header.addSubview(headerLabel)
            
            return header
        } else {
            return UICollectionReusableView()
        }
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        selectedPokemon = (fetchedResultsController.objectAtIndexPath(indexPath) as! Pokemon)
        performSegueWithIdentifier("detailSegue", sender: self)
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let vc = segue.destinationViewController as! UINavigationController
            let pdvc = vc.childViewControllers[0] as! PokeDetailViewController
            pdvc.selectedPokemon = selectedPokemon
        }
    }

}
