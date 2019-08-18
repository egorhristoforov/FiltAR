//
//  RoundedButton.swift
//  FiltAR
//
//  Created by Egor on 18/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {
    
    override func awakeFromNib() {
        setTitleColor(UIColor.white, for: .normal)
        setTitleColor(UIColor.black.withAlphaComponent(0.8), for: .highlighted)
        
        layer.masksToBounds = true
        layer.cornerRadius = 16
        layer.borderWidth = 0.6
        layer.borderColor = UIColor.white.cgColor
    }

    override open var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.backgroundColor = self.isHighlighted ? UIColor.white : UIColor.clear
            }
        }
    }

}
