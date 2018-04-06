//
//  ViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/6/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import ARKit

class GameViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var guideView: GuideView!
    @IBOutlet var gameViews: [UIView]!
    @IBOutlet var startViews: [UIView]!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var birdCountLabel: UILabel!
    
    // The planes we're showing
    private var planeForAnchor: [ARAnchor: HorizontalPlane] = [:]
    // The selected planes we have
    private var selectedPlane: HorizontalPlane?
    // Whether or not we should show horizontal planes
    private var showHorizontalPlanes = true {
        didSet {
            for plane in planeForAnchor.values {
                plane.isHidden = !showHorizontalPlanes
            }
        }
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
        sceneView.scene.physicsWorld.contactDelegate = GameManager.shared
        
        GameManager.shared.delegate = self
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
        
        // Hide the gameView by default, show uiview
        for view in gameViews { view.alpha = 0 }
        for view in startViews { view.alpha = 1 }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: Actions
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case pauseButton:
            GameManager.shared.togglePauseState()
            // Show a button to denote the other state (e.g. if paused, show play)
            pauseButton.setImage(GameManager.shared.getPauseState() ? #imageLiteral(resourceName: "play") : #imageLiteral(resourceName: "pause"),
                                 for: .normal)
        default:
            fatalError("Button press unhandled in GameViewController")
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) { }
}

// MARK: HorizontalPlane functioning

extension GameViewController {
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

// MARK: GameManagerDelegate functions

extension GameViewController: GameManagerDelegate {
    @objc func gameDidStart() {
        showHorizontalPlanes = false
        
        // show the gameView, but hide the start buttons
        for view in gameViews { view.alpha = 1 }
        for view in startViews { view.alpha = 0 }
    }
    
    @objc func waveDidComplete(waveNumber: Int) {
        birdCountLabel.text = "\(waveNumber)"
    }
    
    @objc func gameWillEnd(withPointTotal points: Int) {
        DispatchQueue.main.async {
            // Create an authentication view so the user can post their scores
            // CREATE VIEW CONTROLLER THING HERE
            
            self.showHorizontalPlanes = true
            GameManager.shared.gameNode.isHidden = true
            
            // Hide the gameViews
            for view in self.gameViews { view.alpha = 0 }
            
            self.performSegue(withIdentifier: "showAuthSegue", sender: self)
        }
    }
}

// MARK: ARSCNViewDelegate functions

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
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            let plane = HorizontalPlane(anchor: anchor)
            plane.isHidden = !showHorizontalPlanes
            planeForAnchor[anchor] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor,
            let plane = planeForAnchor[anchor] {
            plane.update(for: anchor)
            if selectedPlane?.anchor == anchor {
                updateGameSceneForAnchor(anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let plane = planeForAnchor.removeValue(forKey: anchor) {
            if plane == self.selectedPlane {
                let nextPlane = planeForAnchor.values.first!
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
        
        // If we hit a node and the game isn't paused...
        if let hitObject = hits.first?.node,
           !GameManager.shared.getPauseState() {
            
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
                GameManager.shared.startGame()
            }
            if hitObject == GameManager.shared.ocean {
                // Gets the tapped position relative to the worldScene so we can add the whale there
                let tapPos = GameManager.shared.ocean.convertPosition(hits.first!.localCoordinates,
                                                                      to: GameManager.shared.worldScene)
                GameManager.shared.spawnWhale(atWorldScenePosition: tapPos)
            }
        }
    }
}
