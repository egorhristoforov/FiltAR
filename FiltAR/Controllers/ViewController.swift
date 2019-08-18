//
//  ViewController.swift
//  FiltAR
//
//  Created by Egor on 21/07/2019.
//  Copyright © 2019 Egor. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UINavigationControllerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var imageView: UIImageView!
    private let imagePicker = UIImagePickerController()
    
    private var boxNodes = [SCNNode]()
    private var filters = [CIFilter?]()
    private var blurRadius = 2
    private var areaRadius: CGFloat = 0.35 {
        didSet {
            startingPosition = SCNVector3(0, 0, -areaRadius)
        }
    }
    private var nodesCount = 0
    private var startingPosition = SCNVector3(0, 0, 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
        
        filters = [CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur"), CIFilter(name: "CIGaussianBlur")]
        nodesCount = filters.count
        
        sceneView.delegate = self
        
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin]
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        areaRadius = (0.18 + 0.28) / (2 * sin(2 * CGFloat.pi / CGFloat(2 * nodesCount)))
        
        for i in 0..<nodesCount {
            let boxNode = createBox(boxWidth: 0.18, boxHeight: 0.28, boxLength: 0.01)
            boxNode.position = getPositionForBox(withIndex: i)
            boxNodes.append(boxNode)
            scene.rootNode.addChildNode(boxNode)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    // MARK: - Create boxes with filters
    
    func createBox(boxWidth width: CGFloat, boxHeight height: CGFloat, boxLength length: CGFloat, boxRadius radius: CGFloat = 0) -> SCNNode {
        
        let borderBox = SCNBox(width: width + 0.01, height: height + 0.01, length: length + 0.01, chamferRadius: radius)
        
        let borderMaterial = SCNMaterial()
        borderMaterial.diffuse.contents = UIColor(cgColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        
        borderBox.materials = [borderMaterial]
        
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: radius)
        
        let frontSideMaterial = SCNMaterial()
        frontSideMaterial.diffuse.contents = UIImage(named: "SteveJobs")
        
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
            currentFilter.setValue(blurRadius, forKey: kCIInputRadiusKey)
            
            if let output = currentFilter.outputImage {
                if let cgimg = context.createCGImage(output, from: output.extent) {
                    let processedImage = UIImage(cgImage: cgimg)
                    imageView.image = processedImage
                    blurRadius += 2
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
    
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            //imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
