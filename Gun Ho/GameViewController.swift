//
//  ViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/6/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class GameViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var guideView: GuideView!
    
    var planes: [ARAnchor: HorizontalPlane] = [:]
    var selectedPlane: HorizontalPlane?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        let tapGesture =
            UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main-game.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = GameManager.shared
        
        GameManager.shared.rootNode = sceneView.scene.rootNode
        GameManager.shared.gameNode.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func addToNode(rootNode: SCNNode) {
        SCNTransaction.perform {
            GameManager.shared.rootNode = rootNode
            GameManager.shared.gameNode.removeFromParentNode()
            rootNode.addChildNode(GameManager.shared.gameNode)
            //GameManager.shared.gameNode.scale = SCNVector3(0.1, 0.1, 0.1)
        }
    }
    
    func updateGameSceneForAnchor(anchor: ARPlaneAnchor) {
        let worldSize: Float = 60
        let minSize = min(anchor.extent.x, anchor.extent.z)
        let scale = minSize / worldSize
        //GameManager.shared.gameNode.scale = SCNVector3(x: scale, y: scale, z: scale)
        GameManager.shared.gameNode.position = SCNVector3(anchor.center)
    }
}

// MARK: - ARSCNViewDelegate

extension GameViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        /*
         Running below in the simulator does not work since we can never get
         the ambitient light intensity.
         However, on a physical device, this causes the light intensity of the
         normal lights to match the camera's captured intensity.
         */
        if let frame = sceneView.session.currentFrame,
            let lightIntensity = frame.lightEstimate?.ambientIntensity {
            
            GameManager.shared.updateLightingIntensity(toLightIntensity: lightIntensity)
        }
        
        for object in GameManager.shared.gameObjects {
            object.performLogicForFrame()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = HorizontalPlane(anchor: anchor)
            planes[anchor] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor,
            let plane = planes[anchor] {
            plane.update(for: anchor)
            if selectedPlane?.anchor == anchor {
                updateGameSceneForAnchor(anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let plane = planes.removeValue(forKey: anchor) {
            if plane == self.selectedPlane {
                let nextPlane = planes.values.first!
                addToNode(rootNode: nextPlane)
                updateGameSceneForAnchor(anchor: nextPlane.anchor)
            }
            plane.removeFromParentNode()
        }
    }
}

// MARK: UIGestureRecognizerDelegate

extension GameViewController: UIGestureRecognizerDelegate {
    @objc func handleTap(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: sceneView)
        let hits = sceneView.hitTest(location, options: nil)
        if let hitObject = hits.first?.node {
            if let boat = hitObject.boatParent {
                boat.decrementHealth()
                boat.shake()
            }
            if let selectedPlane = hitObject as? HorizontalPlane {
                // TODO: Put this into a function...
                self.selectedPlane?.isHidden = false
                self.selectedPlane = selectedPlane
                self.selectedPlane?.isHidden = true
                GameManager.shared.gameNode.isHidden = false
                
                guideView.setLabelTextToStep(type: .startGame)
                addToNode(rootNode: selectedPlane.parent!)
                updateGameSceneForAnchor(anchor: selectedPlane.anchor)
                GameManager.shared.performGameStartSequence()
            }
        }
    }
}
