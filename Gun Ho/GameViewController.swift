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
        
        guard let worldScene =
            scene.rootNode.childNode(withName: "worldScene", recursively: false) else {
                fatalError("Could not find world scene. Was it renamed?")
        }
        GameManager.shared.worldScene = worldScene
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            let boat = MediumBoat()
            
            let randomNum = Double(arc4random())
            let randomUnitVector = SCNVector3(sin(randomNum), 0, cos(randomNum))
            
            boat.position = SCNVector3(randomUnitVector.x * 0.45, -1, randomUnitVector.z * 0.45)
            self.sceneView.scene.rootNode.addChildNode(boat)
            boat.look(at: self.sceneView.getNode(withName: "island").position)
            
            SCNTransaction.perform {
                SCNTransaction.animationDuration = 5
                boat.position = SCNVector3(0, -1, 0)
            }
        }
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
