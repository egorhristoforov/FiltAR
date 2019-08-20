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
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    private var defaultCenterModal = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        blurEffect.alpha = 0
        panGestureRecognizer.maximumNumberOfTouches = 1
        defaultCenterModal = modalView.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.375, animations: {
            self.blurEffect.alpha = 1
        }, completion: nil)
    }
    
    func setupUI() {
        modalView.roundCorners(corners: [.topLeft, .topRight], radius: 14.0)
        
    }

    @IBAction func closeModal(_ sender: UIButton) {
        self.blurEffect.alpha = 0
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            if view.center.y + translation.y >= defaultCenterModal.y {
                view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
            }
            
            if sender.state == .ended {
                if view.center.y + translation.y >= defaultCenterModal.y * 1.3 {
                    self.blurEffect.alpha = 0
                    self.dismiss(animated: true, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.2) {
                        view.center.y = self.defaultCenterModal.y
                    }
                }
            }
        }
        
        sender.setTranslation(CGPoint.zero, in: self.view)
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
