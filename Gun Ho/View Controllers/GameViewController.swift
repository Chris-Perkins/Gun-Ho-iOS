//
//  ViewController.swift
//  Gun Ho
//
//  Created by Christopher Perkins on 2/6/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import ARKit
import CDAlertView

class GameViewController: UIViewController {
    
    // MARK: Properties
    
    // Light-status bar display
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // An enum to signify what spawn state we're currently in.
    public enum SpawningMode {
        case whale
        case watermine
        case none
    }
    // The mode we currently spawn in
    private var currentSpawningMode: SpawningMode = .none
    
    // The following arrays are used to help us hide and display views as necessary.
    @IBOutlet var gameViews: [UIView]!
    @IBOutlet var startViews: [UIView]!
    @IBOutlet weak var guideViewBottomConstraint: NSLayoutConstraint!
    
    // The following are references to storyboard views for use in ease of passing information.
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var guideView: GuideView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var birdCountLabel: UILabel!
    @IBOutlet weak var waterMineToggleButton: ToggleableButton!
    @IBOutlet weak var whaleToggleButton: ToggleableButton!
    @IBOutlet weak var buyWaterMineButton: UIButton!
    @IBOutlet weak var buyWhaleButton: UIButton!
    @IBOutlet weak var waterMineCountLabel: UILabel!
    @IBOutlet weak var whaleCountLabel: UILabel!
    
    // The planes we're showing
    private var planeForAnchor: [ARAnchor: HorizontalPlane] = [:] {
        didSet {
            if planeForAnchor.count > 0 {
                guideView?.setLabelTextToStep(type: .selectPlane)
            } else {
                guideView?.setLabelTextToStep(type: .scanPlanes)
            }
        }
    }
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
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main-game.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        sceneView.scene.physicsWorld.contactDelegate = GameManager.shared
        
        // Allows for tap gestures to be recognized in the scene
        let tapGesture =
            UITapGestureRecognizer(target: self,
                                   action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        sceneView.addGestureRecognizer(tapGesture)
        
        // Sets up the GameManager to host the game
        GameManager.shared.delegate = self
        GameManager.shared.scene = sceneView.scene
        GameManager.shared.gameNode.isHidden = true
        
        // Giving the toggle buttons toggle conditions
        whaleToggleButton.canToggle = { return currentWhaleCount > 0 }
        waterMineToggleButton.canToggle = { return currentWaterMineCount > 0 }
        
        // Listen for changes in the whale count or the watermine count
        // Function calls will respond accordingly
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWhaleCountLabel),
                                               name: whaleCountSet,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWaterMineCountLabel),
                                               name: waterMineCountSet,
                                               object: nil)
        
        // Update the bird label
        setBirdLabelToTotalBirdsCount()
        
        // Update the labels to be what is currently stored
        updateWaterMineCountLabel()
        updateWhaleCountLabel()
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
        changeViewVisibilityToState(ofGameStarted: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    /* Whenever we're segueing from this storyboard to the score displayer,
        We must have ended the game. Set the display score to whatever score this is. */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let authVC = segue.destination as? ScoreDisplayViewController {
            // Sets the score for the authentication controller
            if previousScoresReference.count != 0 {
                authVC.displayScore = previousScoresReference[previousScoresReference.count - 1]
            } else {
                // Simply catching out of bounds errors. this shouldn't happen.
                authVC.displayScore = -1
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func buttonPress(_ sender: UIButton) {
        switch sender {
        case infoButton:
            // Shows the info screen
            CDAlertView.createInfoAlert().show()
            
        case pauseButton:
            // Pauses the game
            GameManager.shared.setPauseState(to: true)
            
        case buyWhaleButton:
            // Attempts to buy a whale
            attemptItemBuy(ofBirdPrice: Whale.birdPrice) {
                setWhaleCount(to: currentWhaleCount + 1)
                self.setBirdLabelToTotalBirdsCount()
            }
            
        case buyWaterMineButton:
            // Attempts to buy a watermine
            attemptItemBuy(ofBirdPrice: WaterMine.birdPricePerFive) {
                setWaterMineCount(to: currentWaterMineCount + 5)
                self.setBirdLabelToTotalBirdsCount()
            }
            
        case waterMineToggleButton:
            // Can't spawn both whales and watermines
            if whaleToggleButton.isToggled {
                whaleToggleButton.isToggled = false
            }
            currentSpawningMode = waterMineToggleButton.isToggled ? .watermine : .none
            
        case whaleToggleButton:
            // Can't spawn both whales and watermines
            if waterMineToggleButton.isToggled {
                waterMineToggleButton.isToggled = false
            }
            currentSpawningMode = whaleToggleButton.isToggled ? .whale : .none
            
        default:
            fatalError("Button press unhandled in GameViewController")
        }
    }
    
    // Allows view controllers to unwind back here from segues
    @IBAction func unwind(segue: UIStoryboardSegue) { }
    
    // MARK: Custom functions
    
    // Called by notifications
    private func setBirdLabelToTotalBirdsCount() {
        birdCountLabel.text = "\(currentBirdsCount)"
    }
    
    // Attempts ot buy an item with the given price
    private func attemptItemBuy(ofBirdPrice price: Int, withSuccessCompletion successCompletion: @escaping () -> ()) {
        // If the user hasn't seen the buy warning, then show it.
        if !userSawBuyWarning {
            // Make them see the buy warning.
            setUserSawBuyWarning(to: true)
            CDAlertView.createBuyWarningAlert().show()
            
            // Don't actually attempt the transaction now; user has to press again.
            return
        }
        
        if price <= currentBirdsCount {
            setBirdCount(to: currentBirdsCount - price)
            successCompletion()
        } else {
            CDAlertView(title: NSLocalizedString("Trading.Failure.Title",
                                                 comment: ""),
                        message: NSLocalizedString("Trading.Failure.Desc",
                                                   comment: ""),
                        type: CDAlertViewType.error).showAfterAddingOkayAction()
        }
    }
    
    // Changes the visibility of the game views to the given state.
    private func changeViewVisibilityToState(ofGameStarted gameStarted: Bool) {
        for view in gameViews { view.isHidden = !gameStarted }
        for view in startViews { view.isHidden = gameStarted }
        
        UIView.animate(withDuration: 0.25) {
            self.guideViewBottomConstraint.constant = gameStarted ? self.guideView.frame.height : 0
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: NotificationCenter Listening

extension GameViewController {
    @objc internal func updateWaterMineCountLabel() {
        waterMineCountLabel.text = "\(currentWaterMineCount)"
    }
    
    @objc internal func updateWhaleCountLabel() {
        whaleCountLabel.text = "\(currentWhaleCount)"
    }
}

// MARK: HorizontalPlane functioning

extension GameViewController {
    func addToNode(rootNode: SCNNode) {
        SCNTransaction.perform {
            GameManager.shared.rootNode = rootNode
            GameManager.shared.gameNode.removeFromParentNode()
            rootNode.addChildNode(GameManager.shared.gameNode)
        }
    }
    
    func updateGameSceneForAnchor(anchor: ARPlaneAnchor) {
        GameManager.shared.gameNode.position = SCNVector3(anchor.center)
    }
}

// MARK: GameManagerDelegate functions

extension GameViewController: GameManagerDelegate {
    @objc func gameDidStart() {
        showHorizontalPlanes = false
        birdCountLabel.text = "+\(0)"
        
        // show the gameView, but hide the start buttons
        changeViewVisibilityToState(ofGameStarted: true)
    }
    
    @objc func gamePauseStateChanged(toState state: Bool) {
        // We only need to modify the storyboard if we're in an active game
        if GameManager.shared.inActiveGame {
            // Hide the pause button since we have the pause vc open now.
            pauseButton.isHidden = state
            if state {
                performSegue(withIdentifier: "showPauseSegue", sender: self)
            }
        }
    }
    
    @objc func waveDidComplete(waveNumber: Int) {
        setBirdCount(to: currentBirdsCount + 1)
        birdCountLabel.text = "+\(waveNumber)"
    }
    
    @objc func gameDidEnd() {
        DispatchQueue.main.async {
            // Show the horizontal planes for anchor selection
            self.showHorizontalPlanes = true
            GameManager.shared.gameNode.isHidden = true
            
            // Hide views related to the game
            self.changeViewVisibilityToState(ofGameStarted: false)
            
            // User should not be toggling any buttons anymore
            self.waterMineToggleButton.isToggled = false
            self.whaleToggleButton.isToggled = false
            // The spawn state is none since we have nothing selected
            self.currentSpawningMode = .none
            
            // Reset the bird score
            self.setBirdLabelToTotalBirdsCount()
            
            // Go to the correct game over view controller
            self.performSegue(withIdentifier: "showGameOver\(demoModeIsActive ? "Demo" : "Live")Segue", sender: self)
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
                GameManager.shared.forceQuitSession()
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
        if let hitObject = hits.first?.node {
            if GameManager.shared.inActiveGame {
                if let boat = hitObject.boatParent {
                    boat.decrementHealth()
                    boat.shake()
                } else if hitObject == GameManager.shared.ocean {
                    // Gets the tapped position relative to the worldScene so we can add the whale there
                    let tapPos = GameManager.shared.ocean.convertPosition(hits.first!.localCoordinates,
                                                                          to: GameManager.shared.worldScene)
                    switch currentSpawningMode {
                    case .watermine:
                        if currentWaterMineCount > 0 {
                            GameManager.shared.spawnWaterMine(atWorldScenePosition: tapPos)
                            setWaterMineCount(to: currentWaterMineCount - 1)
                            
                            if currentWaterMineCount <= 0 {
                                waterMineToggleButton.isToggled = false
                            }
                        }
                    case .whale:
                        if currentWhaleCount > 0 {
                            GameManager.shared.spawnWhale(atWorldScenePosition: tapPos)
                            setWhaleCount(to: currentWhaleCount - 1)
                            
                            if currentWhaleCount <= 0 {
                                whaleToggleButton.isToggled = false
                            }
                        }
                    default:
                        // Do nothing (no spawning state called)
                        break
                    }
                }
            } else {
                if let selectedPlane = hitObject as? HorizontalPlane {
                    // TODO: Put this into a function...
                    self.selectedPlane?.isHidden = false
                    self.selectedPlane = selectedPlane
                    self.selectedPlane?.isHidden = true
                    GameManager.shared.gameNode.isHidden = false
                    
                    addToNode(rootNode: selectedPlane.parent!)
                    updateGameSceneForAnchor(anchor: selectedPlane.anchor)
                    GameManager.shared.startGame()
                }
            }
        }
    }
}
