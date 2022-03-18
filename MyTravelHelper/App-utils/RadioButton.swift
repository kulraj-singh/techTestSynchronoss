//
//  RadioButton.swift
//  MyTravelHelper
//
//  Created by Kulraj on 18/03/22.
//  Copyright © 2022 Sample. All rights reserved.
//

import UIKit

class RadioButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setImage(UIImage(named: "selectedRadioButton"), for: .selected)
        setImage(UIImage(named: "unselectedRadioButton"), for: .normal)
    }

}
