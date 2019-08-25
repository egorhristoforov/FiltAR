//
//  FilterModalViewController.swift
//  FiltAR
//
//  Created by Egor on 19/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit

protocol FilterModalDelegate {
    func updateController(withImage image: UIImage)
}

class FilterModalViewController: UIViewController {

    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var blurEffect: UIVisualEffectView!
    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var modalTitleLabel: UILabel!
    @IBOutlet weak var modalImage: UIImageView!
    @IBOutlet weak var modalSlider: UISlider!
    @IBOutlet weak var modalApplyButton: UIButton!
    @IBOutlet weak var modalResetButton: UIButton!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    private var defaultCenterModal = CGPoint.zero
    private var animator: UIViewPropertyAnimator?
    
    private var processedImage: UIImage!
    
    private var context: CIContext!
    private var beginImage: CIImage!
    
    var image: UIImage!
    var titleLabelText: String!
    var filter: Filter!
    
    var delegate: FilterModalDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupData()
        blurEffect.alpha = 0
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        defaultCenterModal = modalView.center
        
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
            self.blurEffect.effect = nil
        })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0.375, animations: {
            self.blurEffect.alpha = 1
        }, completion: nil)
    }
    
    func setupUI() {
        modalView.roundCorners(corners: [.topLeft, .topRight], radius: 14.0)
        closeView.layer.masksToBounds = true
        closeView.layer.cornerRadius = 2
        modalApplyButton.layer.masksToBounds = true
        modalApplyButton.layer.cornerRadius = 14
        
        modalResetButton.layer.masksToBounds = true
        modalResetButton.layer.cornerRadius = 14
        modalResetButton.layer.borderWidth = 0.6
        modalResetButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func setupData() {
        modalImage.image = image
        modalTitleLabel.text = titleLabelText
        processedImage = image
        
        beginImage = CIImage(image: image)
        filter.filter.setValue(beginImage, forKey: kCIInputImageKey)
        
        context = CIContext(options:nil)
        modalSlider.minimumValue = filter.startValue
        modalSlider.maximumValue = filter.endValue
    }
    
    @IBAction func changedSliderValue(_ sender: UISlider) {
        
        let sliderValue = sender.value
        
        filter.updateKeyValue(newValue: sliderValue)
        guard let outputImage = filter.filter.outputImage else { return }
        
        guard let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let newImage = UIImage(cgImage: cgimg)
        
        modalImage.image = newImage
        processedImage = newImage
    }
    
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        modalImage.image = image
        processedImage = image
        modalSlider.value = 0
    }
    
    @IBAction func applyButtonTapped(_ sender: UIButton) {
        delegate.updateController(withImage: processedImage)
        closeModal()
    }
    
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        defer {
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
        
        guard let view = sender.view else { return }
        
        let translation = sender.translation(in: self.view)
        
        if view.center.y + translation.y >= defaultCenterModal.y * 1.2 {
            view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y / 2.5)
            animator?.fractionComplete = CGFloat((abs(defaultCenterModal.y - view.center.y) / defaultCenterModal.y))
        } else if view.center.y + translation.y >= defaultCenterModal.y {
            view.center = CGPoint(x: view.center.x, y: view.center.y + translation.y)
            animator?.fractionComplete = CGFloat((abs(defaultCenterModal.y - view.center.y) / defaultCenterModal.y))
        }
        
        if sender.state == .ended {
            if view.center.y + translation.y >= defaultCenterModal.y * 1.2 {
                closeModal()
            } else {
                UIView.animate(withDuration: 0.2) {
                    view.center.y = self.defaultCenterModal.y
                    self.animator?.fractionComplete = CGFloat((abs(self.defaultCenterModal.y - view.center.y) / self.defaultCenterModal.y))
                }
            }
        }
        
    }
    
    func closeModal() {
        blurEffect.alpha = 0
        animator?.stopAnimation(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension FilterModalViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let isSlider = touch.view?.isKind(of: UISlider.self) {
            return !isSlider
        } else {
            return true
        }
    }
}
