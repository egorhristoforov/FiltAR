//
//  MainScreenViewController.swift
//  FiltAR
//
//  Created by Egor on 18/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet weak var startButton: UIButton!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        setupUI()
        
    }
    
    func setupUI() {
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 16
        startButton.layer.borderWidth = 1
        startButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
    }
}

extension MainScreenViewController: UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            dismiss(animated: true, completion: nil)
        }
        
        guard let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
    }
    
}
