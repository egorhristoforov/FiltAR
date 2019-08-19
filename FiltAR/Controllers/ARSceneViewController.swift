//
//  ViewController.swift
//  FiltAR
//
//  Created by Egor on 18/08/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ARSceneViewController: UIViewController, ARSCNViewDelegate {
    
    // MARK: - Outlets and imagePicker
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupImageView: UIImageView!
    @IBOutlet weak var popupSpinner: UIActivityIndicatorView!
    private let imagePicker = UIImagePickerController()
    
    // MARK: - Global Variables
    
    private var boxNodes = [SCNNode]()
    private var filters = [CIFilter?]()
    private var nodesCount = 0
    private var boxWidth: CGFloat = 0.9
    private var startingPosition = SCNVector3(0, 0, 0)
    private var blurRadius: CGFloat = 2
    
    private var areaRadius: CGFloat = 0.35 {
        didSet {
            startingPosition = SCNVector3(0, 0, -areaRadius)
        }
    }
    
    public var pickedImage: UIImage! {
        didSet {
            if pickedImage.size.width > 2000 {
                pickedImage = resizeImage(image: pickedImage, newWidth: 720)
            }
            self.imageView?.image = pickedImage
        }
    }
    
    // MARK: - View lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        setupSaveButtonUI()
        popupView.layer.masksToBounds = true
        popupView.layer.cornerRadius = 14
        
        imageView.image = pickedImage
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        filters = [CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur")]
        nodesCount = filters.count
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let proportion = getProportion(fromImage: pickedImage)
        print("Proportion = \(proportion), boxWidth = \(boxWidth), boxHeight = \(boxWidth * proportion), imageWidth = \(pickedImage!.size.width), imageHeight = \(pickedImage!.size.height)")
        areaRadius = (boxWidth + boxWidth * proportion) / (2 * sin(2 * CGFloat.pi / CGFloat(2 * nodesCount)))
        
        for i in 0..<nodesCount {
            let boxNode = createBox(boxWidth: boxWidth, boxHeight: boxWidth * proportion, boxLength: 0.01)
            boxNode.position = getPositionForBox(withIndex: i)
            boxNodes.append(boxNode)
            scene.rootNode.addChildNode(boxNode)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        let configuration = AROrientationTrackingConfiguration()
        configuration.worldAlignment = .gravity
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    
    // MARK: - ARSCNViewDelegate
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: - Setup UI methods
    
    func setupSaveButtonUI() {
        saveButton.layer.masksToBounds = true
        saveButton.layer.cornerRadius = 16
    }
    
    // MARK: - Create boxes with filters
    
    func createBox(boxWidth width: CGFloat, boxHeight height: CGFloat, boxLength length: CGFloat, boxRadius radius: CGFloat = 0) -> SCNNode {
        
        let borderBox = SCNBox(width: width + 0.01, height: height + 0.01, length: length + 0.01, chamferRadius: radius)
        
        let borderMaterial = SCNMaterial()
        borderMaterial.diffuse.contents = UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        borderBox.materials = [borderMaterial]
        
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: radius)
        
        let frontSideMaterial = SCNMaterial()
        
        frontSideMaterial.diffuse.contents = pickedImage
        
        let rightSideMaterial = SCNMaterial()
        rightSideMaterial.diffuse.contents = UIColor.white
        
        let backSideMaterial = SCNMaterial()
        backSideMaterial.diffuse.contents = UIColor.white
        
        let leftSideMaterial = SCNMaterial()
        leftSideMaterial.diffuse.contents = UIColor.white
        
        let topSideMaterial = SCNMaterial()
        topSideMaterial.diffuse.contents = UIColor.white
        
        let bottomSideMaterial = SCNMaterial()
        bottomSideMaterial.diffuse.contents = UIColor.white
        
        box.materials = [frontSideMaterial, rightSideMaterial, backSideMaterial, leftSideMaterial, topSideMaterial, bottomSideMaterial]
        
        let resultNode = SCNNode()
        let imageNode = SCNNode(geometry: box)
        let borderNode = SCNNode(geometry: borderBox)
        
        borderNode.position = SCNVector3(0, 0, 0)
        imageNode.position = SCNVector3(0, 0, 0.0055)
        
        resultNode.addChildNode(borderNode)
        resultNode.addChildNode(imageNode)
        
        let moveDown = SCNAction.move(by: SCNVector3(0, -0.025, 0), duration: 1)
        let moveUp = SCNAction.move(by: SCNVector3(0,0.025,0), duration: 1)
        let waitAction = SCNAction.wait(duration: 0.1)
        let hoverSequence = SCNAction.sequence([moveUp,waitAction,moveDown, waitAction])
        let loopSequence = SCNAction.repeatForever(hoverSequence)
        resultNode.runAction(loopSequence)
        
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [SCNBillboardAxis.Y, SCNBillboardAxis.X]
        resultNode.constraints = [billboardConstraint]
        
        return resultNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self.view) else { return }
        let hit = sceneView.hitTest(touchLocation)
        if let tappedNode = hit.first?.node {
            guard let image = getImageFromNode(from: tappedNode) else { return }
            guard let nodeIndex = boxNodes.firstIndex(of: tappedNode) else { return }
            guard let currentFilter = filters[nodeIndex] else { return }
            
            let context = CIContext(options: nil)
            
            let beginImage = CIImage(image: image)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            //currentFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
            
            if let output = currentFilter.outputImage {
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    let processedImage = UIImage(cgImage: cgimg)
                    imageView.image = processedImage
                    //blurRadius += 2
                    // do something interesting with the processed image
                }
            }
        }
    }
    
    func getImageFromNode(from node: SCNNode) -> UIImage? {
        guard let material = node.geometry?.materials[0] else { return nil }
        guard let image = material.diffuse.contents as? UIImage else { return nil }
        
        return image
    }
    
    func getPositionForBox(withIndex index: Int) -> SCNVector3 {
        
        if index == 0 {
            return startingPosition
        }
        
        let l = 2 * CGFloat.pi * CGFloat(index) / CGFloat(nodesCount) - CGFloat.pi / 2
        var x: CGFloat = 0
        var z: CGFloat = 0
        if l == CGFloat.pi / 2 {
            x = 0
            z = areaRadius
        } else if l < CGFloat.pi / 2{
            x = sqrt(pow(areaRadius, 2) / (1 + pow(tan(l), 2)))
            z = tan(l) * x
        } else {
            x = -sqrt(pow(areaRadius, 2) / (1 + pow(tan(l), 2)))
            z = tan(l) * x
        }
        
        return SCNVector3(x, 0, z)
        
    }
    
    @IBAction func rigthBarItemTapped(_ sender: UIBarButtonItem) {
        
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
        
        self.present(alert, animated: true, completion: nil)

        
    }
    
    func updateNodes(withImage image: UIImage) {
        let proportion = getProportion(fromImage: image)
        areaRadius = (boxWidth + boxWidth * proportion) / (2 * sin(2 * CGFloat.pi / CGFloat(2 * nodesCount)))
        
        for node in boxNodes {
            
            let i = boxNodes.firstIndex(of: node)!
            node.position = getPositionForBox(withIndex: i)
            
            let imageNode = node.childNodes[1]
            let borderNode = node.childNodes[0]

            if let box = node.geometry as? SCNBox {
                box.width = boxWidth
                box.height = boxWidth * proportion
            }

            if let box = borderNode.geometry as? SCNBox {
                box.width = boxWidth + 0.01
                box.height = boxWidth * proportion + 0.01
            }

            if let box = imageNode.geometry as? SCNBox {
                box.width = boxWidth
                box.height = boxWidth * proportion
            }
            
            imageNode.geometry?.materials[0].diffuse.contents = image
        }
    }
    
    // MARK: - Save imageView image to photo library
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        
        if let imageForSaving = imageView.image {
            saveButton.isEnabled = false
            popupImageView.isHidden = true
            
            popupView.isHidden = false
            popupView.alpha = 1
            popupSpinner.startAnimating()
            
            UIImageWriteToSavedPhotosAlbum(imageForSaving, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            popupImageView.image = UIImage(named: "ErrorIcon")
            print("Error with saving photo, \(error)")
        } else {
            popupImageView.image = UIImage(named: "SuccessIcon")
        }
        
        popupSpinner.stopAnimating()
        popupImageView.alpha = 0
        popupImageView.isHidden = false
        UIView.animate(withDuration: 0.5) {
            self.popupImageView.alpha = 1
        }
        
        
        UIView.animate(withDuration: 0.2, delay: 2, animations: {
            self.popupView.alpha = 0
        }) { (_) in
            self.popupView.isHidden = true
            self.saveButton.isEnabled = true
        }
    }
    
    // MARK: - Resize image function
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // MARK: - Get proportion from image
    
    func getProportion(fromImage image: UIImage) -> CGFloat {
        let pixelWidth = image.size.width
        let pixelHeight = image.size.height
        let proportion = pixelHeight / pixelWidth
        
        return proportion
    }
    
    
}

// MARK: - Extension for imagePicker

extension ARSceneViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dismiss(animated: true, completion: nil)
            
            self.pickedImage = pickedImage
            updateNodes(withImage: self.pickedImage)
            
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
}
