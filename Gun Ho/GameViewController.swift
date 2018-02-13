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

class GameViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Gets the y-position of the ocean's top
    private var floorHeight: Float {
        guard let floorNode = sceneView.scene.rootNode.childNode(withName: "floor", recursively: false) else {
            fatalError("Floor Node could not be found for the sceneview's scene!")
        }
        return floorNode.position.y
    }
    // Gets the lights in the scene
    private var lights: [SCNLight] {
        guard let lightsNode
            = sceneView.scene.rootNode.childNode(withName: "Lights", recursively: false) else  {
            fatalError("Could not find lights node")
        }
        
        return lightsNode.childNodes.map({ (node) -> SCNLight in
            return node.light!
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main-game.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let boat = VikingBoat()
        boat.position = SCNVector3(0, floorHeight + boat.floatHeight, -5)
        sceneView.scene.rootNode.addChildNode(boat)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*let node = sceneView.scene.rootNode.childNode(withName: "ship", recursively: false)!
        SCNTransaction.animationDuration = 1
        node.position = SCNVector3(1, 1, 1)*/
        /*node.addAnimation(
            CABasicAnimation.createAnimation(withKeyPath: #keyPath(SCNNode.transform),
                                             startPosition: SCNVector3(0, 0, 0),
                                             endPosition: SCNVector3(1, 1, 1),
                                             duration: 5),
            forKey: nil)*/
        
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !Platform.isSimulator {
            guard let frame = sceneView.session.currentFrame,
                let lightIntensity = frame.lightEstimate?.ambientIntensity else {
                    fatalError("Could not get light estimate")
            }
            
            for light in lights {
                light.intensity = lightIntensity
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
