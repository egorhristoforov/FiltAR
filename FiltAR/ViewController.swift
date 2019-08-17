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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showWorldOrigin]
        
        let scene = SCNScene()
        
        let boxNode = createBox(boxWidth: 0.18, boxHeight: 0.28, boxLength: 0.01)
        boxNode.position = SCNVector3(0, 0, -0.5)
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [SCNBillboardAxis.Y, SCNBillboardAxis.X]
        boxNode.constraints = [billboardConstraint]
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.worldAlignment = .gravity
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let camera = sceneView.pointOfView {
            let nodes = sceneView.scene.rootNode.childNodes
            guard !nodes.isEmpty else {return}
            for node in nodes {
                //node.simdScale = simd_float3(0.5, 0.5, 0.5)
                //node.position = SCNVector3(camera.position.x, camera.position.y, camera.position.z - 0.5)
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    /*override func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let pov = sceneView.pointOfView
        let position = pov?.position
        
        let x = position?.x
        let y = position?.y
        let z = position?.z
        
        
    }*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
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
     
        return resultNode
    }
}
