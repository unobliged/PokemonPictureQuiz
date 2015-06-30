//
//  PokeCollectionViewCell.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 6/29/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit

class PokeCollectionViewCell: UICollectionViewCell {
    
    var pokeImageView: UIImageView!
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label = UILabel(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        label.text = ""
        contentView.addSubview(label)
        
        pokeImageView = UIImageView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        contentView.addSubview(pokeImageView)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
