//
//  PlayerProgressView.swift
//  meridelib
//
//  Created by Romal Tandel on 2/19/18.
//

import UIKit

import UIKit

public class PlayerProgressView: UIView {
    
    @IBOutlet weak var statusImage: UIImageView!
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    @IBOutlet weak var changedTimeLabel: UILabel!
    
    override public func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.backgroundColor = UIColor.init(white: 0.2, alpha: 0.8)
        self.isUserInteractionEnabled = false
        
        self.statusImage.contentMode = UIViewContentMode.scaleAspectFit
    }
}

