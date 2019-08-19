//
//  MainScreenViewController.swift
//  FiltAR
//
//  Created by Egor on 18/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit

class MainScreenViewController: UIViewController {
    @IBOutlet weak var startButton: RoundedButton!
    let imagePicker = UIImagePickerController()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Where to take photo?", message: nil, preferredStyle: .actionSheet)
        
        let actionFromLibrary = UIAlertAction(title: "From photo library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let actionFromCamera = UIAlertAction(title: "From camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionFromCamera)
        alert.addAction(actionFromLibrary)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }

        self.present(alert, animated: true, completion: nil)
    }  
}

extension MainScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dismiss(animated: true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ARScene") as! ARSceneViewController
            
            vc.pickedImage = pickedImage
            print("Show vc")
            //self.present(vc, animated:true, completion:nil)
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

}
