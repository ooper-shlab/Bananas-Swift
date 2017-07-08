//
//  AAPLGameSimulation.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/21.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  This class manages the global state of the game. It handles SCNSceneRendererDelegate methods for participating in the update/render loop, polls for input (directly for game controllers and via AAPLSceneView for key/touch input), and delegates game logic to the AAPLGameLevel object.

 */

import SceneKit

import GLKit
import GameController
import SpriteKit

@objc(AAPLGameUIState)
protocol AAPLGameUIState: NSObjectProtocol {
    
    var score: Int {get}
    var coinsCollected: Int {get}
    var bananasCollected: Int {get}
    var secondsRemaining: TimeInterval {get}
    var scoreLabelLocation: CGPoint {get set}
    
}


enum AAPLGameState: Int {
    case preGame = 0
    case inGame
    case paused
    case postGame
    static let Count = postGame.rawValue + 1
}

let GameCollisionCategoryGround         = 1 << 2
let GameCollisionCategoryBanana         = 1 << 3
let GameCollisionCategoryPlayer         = 1 << 4
let GameCollisionCategoryLava           = 1 << 5
let GameCollisionCategoryCoin           = 1 << 6
let GameCollisionCategoryCoconut        = 1 << 7
let GameCollisionCategoryNoCollide      = 1 << 14

let NodeCategoryTorch          = 1 << 2
let NodeCategoryLava           = 1 << 3
let NodeCategoryLava2          = 1 << 4

@objc(AAPLGameSimulation)
class AAPLGameSimulation: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    
    var gameLevel = AAPLGameLevel()
    var gameUIScene: AAPLInGameScene?
    private var _gameState: AAPLGameState = .paused
    private var controller: GCController? {
        didSet {
            didSetController(oldValue)
        }
    }
    
    
    private var _walkSpeed: CGFloat = 0
    private var _previousUpdateTime: TimeInterval = 0
    private var _previousPhysicsUpdateTime: TimeInterval = 0
    private var _deltaTime: TimeInterval = 0
    
    private var desaturationTechnique: SCNTechnique!
    
    // Singleton for easy lookup
    static let sim = AAPLGameSimulation()
    
    private func setupTechniques() {
        
        // The scene can be de-saturarted as a full screen effect.
        let url = Bundle.main.url(forResource: "art.scnassets/techniques/desaturation", withExtension: "plist")
        self.desaturationTechnique = SCNTechnique(dictionary: NSDictionary(contentsOf: url!)! as! [String : Any])
        self.desaturationTechnique.setValue(0.0, forKey: "Saturation")
    }
    
    override init() {
        super.init()
        
        // We create one level in our simulation.
        
        // Register ourself as a listener to physics callbacks.
        let levelNode = self.gameLevel.createLevel()
        self.rootNode.addChildNode(levelNode!)
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = SCNVector3Make(0, -800, 0)
        
        self.setupTechniques()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setPostGameFilters() {
        SCNTransaction.begin()
        
        self.desaturationTechnique.setValue(1.0, forKey: "Saturation")
        
        SCNTransaction.animationDuration = 1.0
        
        SCNTransaction.commit()
        
        let appDelegate = AAPLAppDelegate.sharedAppDelegate()
        appDelegate.scnView.technique = self.desaturationTechnique
    }
    
    private func setPauseFilters() {
        SCNTransaction.begin()
        
        self.desaturationTechnique.setValue(1.0, forKey: "Saturation")
        
        SCNTransaction.animationDuration = 1.0
        self.desaturationTechnique.setValue(0.0, forKey: "Saturation")
        
        SCNTransaction.commit()
        
        let appDelegate = AAPLAppDelegate.sharedAppDelegate()
        appDelegate.scnView.technique = self.desaturationTechnique
    }
    
    private func setPregameFilters() {
        
        SCNTransaction.begin()
        
        self.desaturationTechnique.setValue(1.0, forKey: "Saturation")
        
        SCNTransaction.animationDuration = 1.0
        self.desaturationTechnique.setValue(0.0, forKey: "Saturation")
        
        SCNTransaction.commit()
        
        let appDelegate = AAPLAppDelegate.sharedAppDelegate()
        appDelegate.scnView.technique = self.desaturationTechnique
    }
    
    private func setIngameFilters() {
        SCNTransaction.begin()
        
        self.desaturationTechnique.setValue(0.0, forKey: "Saturation")
        
        SCNTransaction.animationDuration = 1.0
        self.desaturationTechnique.setValue(1.0, forKey: "Saturation")
        SCNTransaction.commit()
        
        let dropTechnique = SCNAction.wait(duration: 1.0)
        
        let appDelegate = AAPLAppDelegate.sharedAppDelegate()
        appDelegate.scnView.scene!.rootNode.runAction(dropTechnique) {
            appDelegate.scnView.technique = nil
        }
    }
    
    var gameState: AAPLGameState {
        get {
            return _gameState
        }
        set(newState) {
            // Ignore redundant state changes.
            if _gameState == newState {
                return
            }
            
            // Change the UI system according to gameState.
            self.gameUIScene?.gameState = newState
            
            // Only reset the level from a non paused mode.
            if newState == .inGame && _gameState != .paused {
                self.gameLevel.resetLevel()
            }
            _gameState = newState
            
            // Based on the new game state... set the saturation value
            // that the techniques will use to render the scenekit view.
            if _gameState == .postGame {
                self.setPostGameFilters()
            } else if _gameState == .paused {
                AAPLGameSimulation.sim.playSound("deposit.caf")
                self.setPauseFilters()
            } else if _gameState == .preGame {
                self.setPregameFilters()
            } else {
                AAPLGameSimulation.sim.playSound("ack.caf")
                self.setIngameFilters()
            }
        }
    }
    
    /*! Our main input pump for the app.
    */
    func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if _previousUpdateTime == 00 {
            _previousUpdateTime = time
        }
        _deltaTime = time - _previousUpdateTime
        _previousUpdateTime = time
        
        let aView = aRenderer as! AAPLSceneView
        
        var pressingLeft = false
        var pressingRight = false
        var pressingJump = false
        
        let gamePad = self.controller?.gamepad
        let extGamePad = self.controller?.extendedGamepad
        
        if gamePad?.dpad.left.isPressed ?? false || extGamePad?.leftThumbstick.left.isPressed ?? false {
            pressingLeft = true
        }
        
        if gamePad?.dpad.right.isPressed ?? false || extGamePad?.leftThumbstick.right.isPressed ?? false {
            pressingRight = true
        }
        
        if gamePad?.buttonA.isPressed ?? false ||
            gamePad?.buttonB.isPressed ?? false ||
            gamePad?.buttonX.isPressed ?? false ||
            gamePad?.buttonY.isPressed ?? false ||
            gamePad?.leftShoulder.isPressed ?? false ||
            gamePad?.rightShoulder.isPressed ?? false
        {
            pressingJump = true
        }
        
        if aView.keysPressed.contains(AAPLLeftKey) {
            pressingLeft = true
        }
        
        if aView.keysPressed.contains(AAPLRightKey) {
            pressingRight = true
        }
        
        if aView.keysPressed.contains(AAPLJumpKey) {
            pressingJump = true
        }
        
        if self.gameState == .inGame && !self.gameLevel.hitByLavaReset {
            if pressingLeft {
                self.gameLevel.playerCharacter?.walkDirection = .left
            } else if pressingRight {
                self.gameLevel.playerCharacter?.walkDirection = .right
            }
            
            if pressingLeft || pressingRight {
                //Run if not running
                self.gameLevel.playerCharacter?.inRunAnimation = true
            } else {
                //Stop running if running
                self.gameLevel.playerCharacter?.inRunAnimation = false
            }
            
            if pressingJump {
                self.gameLevel.playerCharacter?.performJumpAndStop(false)
            } else {
                self.gameLevel.playerCharacter?.performJumpAndStop(true)
            }
        } else if self.gameState == .preGame || self.gameState == .postGame {
            if pressingJump {
                self.gameState = .inGame
            }
        }
        
        
    }
    
    /*! Our main simulation pump for the app.
    */
    func renderer(_ aRenderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        self.gameLevel.update(_deltaTime, withRenderer: aRenderer as! AAPLSceneView)
    }
    
    //MARK: - Collision handling
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if self.gameState == .inGame {
            // Player to banana, large banana, or coconut
            if contact.nodeA == self.gameLevel.playerCharacter?.collideSphere {
                self.playerCollideWithContact(contact.nodeB, point: contact.contactPoint)
                return
            } else if contact.nodeB == self.gameLevel.playerCharacter?.collideSphere {
                self.playerCollideWithContact(contact.nodeA, point: contact.contactPoint)
                return
            }
            
            // Coconut to anything but the player.
            if contact.nodeB.physicsBody?.categoryBitMask == GameCollisionCategoryCoconut {
                self.handleCollideForCoconut(contact.nodeB as! AAPLCoconut)
            } else if contact.nodeA.physicsBody?.categoryBitMask == GameCollisionCategoryCoconut {
                self.handleCollideForCoconut(contact.nodeA as! AAPLCoconut)
            }
        }
    }
    
    private func playerCollideWithContact(_ node: SCNNode, point contactPoint: SCNVector3) {
        if self.gameLevel.bananas.contains(node) {
            self.gameLevel.collectBanana(node)
        } else if self.gameLevel.largeBananas.contains(node) {
            self.gameLevel.collectLargeBanana(node)
        } else if node.physicsBody?.categoryBitMask == GameCollisionCategoryCoconut {
            self.gameLevel.collideWithCoconut(node, point: contactPoint)
        } else if node.physicsBody?.categoryBitMask == GameCollisionCategoryLava {
            self.gameLevel.collideWithLava()
        }
    }
    
    private func handleCollideForCoconut(_ coconut: AAPLCoconut) {
        // Remove coconut from the world after it has time to fall offscreen.
        coconut.runAction(SCNAction.wait(duration: 3.0)) {
            coconut.removeFromParentNode()
            self.gameLevel.coconuts = self.gameLevel.coconuts.filter{$0 !== coconut}
        }
    }
    
    //MARK: - Game Controller handling
    
    @objc func controllerDidConnect(_ note: Notification) {
        let controller = note.object as! GCController
        
        // Assign the last in controller.
        self.controller = controller
    }
    
    @objc func controllerDidDisconnect(_ note: Notification) {
        self.controller = nil
        
        let currentState = AAPLGameSimulation.sim.gameState
        
        // Pause the if we are in game and the controller was disconnected.
        if currentState == .inGame {
            AAPLGameSimulation.sim.gameState = .paused
        }
    }
    
    private func didSetController(_: GCController?) {
        
        guard let _controller = self.controller else {
            return
        }
        
        _controller.controllerPausedHandler = {myController in
            let currentState = AAPLGameSimulation.sim.gameState
            
            if currentState == .paused {
                AAPLGameSimulation.sim.gameState = .inGame
            } else if currentState == .inGame {
                AAPLGameSimulation.sim.gameState = .paused
            }
        }
    }
    
    //MARK: - Sound & Music
    
    func playSound(_ soundFileName: String?) {
        guard let soundFileName = soundFileName else {
            return
        }
        
        let path = "Sounds/\(soundFileName)"
        self.gameUIScene?.run(SKAction.playSoundFileNamed(path, waitForCompletion: false))
    }
    
    func playMusic(_ soundFileName: String?) {
        guard let soundFileName = soundFileName
            , self.gameUIScene?.action(forKey: soundFileName) != nil else {
                return
        }
        
        let path = "Sounds/\(soundFileName)"
        let repeatAction = SKAction.repeatForever(SKAction.playSoundFileNamed(path, waitForCompletion: true))
        self.gameUIScene?.run(repeatAction, withKey: soundFileName)
    }
    
    //MARK: - Resource Loading convenience
    
    class func pathForArtResource(_ resourceName: String) -> String {
        let ArtFolderRoot = "art.scnassets"
        return "\(ArtFolderRoot)/\(resourceName)"
    }
    
    class func loadNodeWithName(_ name: String?, fromSceneNamed path: String) -> SCNNode? {
        // Load the scene from the specified file
        #if os(OSX)
            let options: [SCNSceneSource.LoadingOption: Any] = [
                SCNSceneSource.LoadingOption.convertToYUp: true,
                SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.playRepeatedly
            ]
        #else
            let options: [SCNSceneSource.LoadingOption: Any] = [
                SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.playRepeatedly
            ]
        #endif
        let scene = SCNScene(named: path,
            inDirectory: nil,
            options: options)
        
        // Retrieve the root node
        var node = scene?.rootNode
        
        // Search for the node named "name"
        if name != nil {
            node = node?.childNode(withName: name!, recursively: true)
        } else {
            node = node?.childNodes[0]
        }
        
        return node
    }
    
    class func loadParticleSystemWithName(_ name: String) -> SCNParticleSystem {
        var path = "level/effects/\(name).scnp"
        path = self.pathForArtResource(path)
        path = Bundle.main.path(forResource: path, ofType: nil)!
        let newSystem = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SCNParticleSystem
        
        let lastPathComponent: String
        if newSystem.particleImage != nil {
            lastPathComponent = (newSystem.particleImage as! URL).lastPathComponent
            path = "level/effects/\(lastPathComponent)"
            path = self.pathForArtResource(path)
            let url = Bundle.main.url(forResource: path, withExtension: nil)
            newSystem.particleImage = url
        }
        return newSystem
    }
    
}
