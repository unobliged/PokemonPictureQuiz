//
//  PokeStatButton.swift
//  Pokemon Picture Quiz
//
//  Created by Brian Ortega on 7/2/15.
//  Copyright (c) 2015 Brian Ortega. All rights reserved.
//

import UIKit

class PokeStatButton: UIButton {
    var ai: UIActivityIndicatorView?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.frame.size = CGSizeMake(75, 75)
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor.blackColor().CGColor
        self.layer.borderWidth = 1
        self.backgroundColor = UIColor(red: 71/255, green: 137/255, blue: 186/255, alpha: 1)
        
        self.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        self.titleLabel?.textAlignment = NSTextAlignment.Center
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.enabled = false
        
        ai = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        ai!.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(ai!)
        ai!.startAnimating()
    }
    
    override func setTitle(title: String?, forState state: UIControlState) {
        super.setTitle(title, forState: state)
        
        self.ai?.stopAnimating()
    }
}
