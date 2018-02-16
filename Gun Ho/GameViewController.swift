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
        
        let tapGesture =
            UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main-game.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let boat = SailBoat()
        boat.position = SCNVector3(2, floorHeight + boat.floatHeight, -10)
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
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        /*
            Running below in the simulator does not work since we can never get
            the ambitient light intensity.
            However, on a physical device, this causes the light intensity of the
            normal lights to match the camera's captured intensity.
        */
        if let frame = sceneView.session.currentFrame,
            let lightIntensity = frame.lightEstimate?.ambientIntensity {
            
            for light in lights {
                light.intensity = lightIntensity
            }
        }
        
        for object in GameManager.shared.getAllGameObjects() {
            object.performLogicForFrame()
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
            }
        }
    }
}
