//
//  FilterModalViewController.swift
//  FiltAR
//
//  Created by Egor on 19/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit

class FilterModalViewController: UIViewController {

    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        blurEffect.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0.28, animations: {
            self.blurEffect.alpha = 1
        }, completion: nil)
    }
    
    func setupUI() {
        modalView.roundCorners(corners: [.topLeft, .topRight], radius: 14.0)
    }

    @IBAction func closeModal(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            self.blurEffect.alpha = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
