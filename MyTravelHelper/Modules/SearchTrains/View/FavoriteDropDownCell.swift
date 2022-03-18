//
//  FavoriteDropDownCell.swift
//  MyTravelHelper
//
//  Created by Kulraj on 18/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import UIKit
import DropDown

class FavoriteDropDownCell: DropDownCell {
    
    @IBOutlet weak var favoriteIcon: UIImageView!
    
    var favoriteToggled: ((Bool) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped))
        favoriteIcon.addGestureRecognizer(tap)
        // Initialization code
    }
    
    @objc func favoriteTapped() {
        favoriteIcon.isHighlighted = !favoriteIcon.isHighlighted
        favoriteToggled?(favoriteIcon.isHighlighted)
    }

}
