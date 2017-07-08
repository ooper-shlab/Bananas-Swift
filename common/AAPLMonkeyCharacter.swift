//
//  AAPLMonkeyCharacter.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/26.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  This class simulates the monkeys in the game. It includes game logic for determining each monkey's actions and also manages the monkey's animations.

 */
import SceneKit

import GLKit

@objc(AAPLMonkeyCharacter)
class AAPLMonkeyCharacter: AAPLSkinnedCharacter {
    
    var rightHand: SCNNode?
    var coconut: SCNNode?
    
    private var isIdle: Bool = false
    private var hasCoconut: Bool = false
    
    func createAnimations() {
        
        self.name = "monkey"
        self.rightHand = self.childNode(withName: "Bone_R_Hand", recursively: true)
        
        isIdle = true
        hasCoconut = false
        
        //load and cache animations
        self.setupTauntAnimation()
        self.setupHangAnimation()
        self.setupGetCoconutAnimation()
        self.setupThrowAnimation()
        
        //-- Sequence: get -> throw
        self.chainAnimation("monkey_get_coconut-1", toAnimation: "monkey_throw_coconut-1")
        
        // start the ball rolling with hanging in the tree.
        self.mainSkeleton?.addAnimation(self.cachedAnimationForKey("monkey_tree_hang-1")!, forKey: "monkey_idle")
    }
    
    private func setupTauntAnimation() {
        let taunt = self.loadAndCacheAnimation(AAPLGameSimulation.pathForArtResource("characters/monkey/monkey_tree_hang_taunt"),
            forKey: "monkey_tree_hang_taunt-1")!
        
        taunt.repeatCount = 0
        
        let ackBlock: SCNAnimationEventBlock = {animation, animatedObject, playingBackward in
            AAPLGameSimulation.sim.playSound("ack.caf")
        }
        
        taunt.animationEvents = [SCNAnimationEvent(keyTime: 0.0, block: ackBlock),
            SCNAnimationEvent(keyTime: 1.0) {animation, animatedObject, playingBackward in
                self.isIdle = true
            }
        ]
    }
    
    private func setupHangAnimation() {
        let hang = self.loadAndCacheAnimation(AAPLGameSimulation.pathForArtResource("characters/monkey/monkey_tree_hang"),
            forKey: "monkey_tree_hang-1")!
        hang.repeatCount = MAXFLOAT
    }
    
    private func setupGetCoconutAnimation() {
        let pickupEventBlock: SCNAnimationEventBlock = {animation, animatedObject, playingBackward in
            self.coconut?.removeFromParentNode()
            self.coconut = AAPLCoconut.coconutProtoObject()
            self.rightHand?.addChildNode(self.coconut!)
            self.hasCoconut = true
        }
        
        let getAnimation = self.loadAndCacheAnimation(AAPLGameSimulation.pathForArtResource("characters/monkey/monkey_get_coconut"), forKey: "monkey_get_coconut-1")
        if getAnimation?.animationEvents == nil {
            getAnimation?.animationEvents = [SCNAnimationEvent(keyTime: 0.40, block: pickupEventBlock)]
        }
        
        getAnimation?.repeatCount = 0
    }
    
    private func setupThrowAnimation() {
        let throwAnim = self.loadAndCacheAnimation(AAPLGameSimulation.pathForArtResource("characters/monkey/monkey_throw_coconut"), forKey: "monkey_throw_coconut-1")!
        throwAnim.speed = 1.5
        if throwAnim.animationEvents == nil || throwAnim.animationEvents!.isEmpty {
            let throwEventBlock: SCNAnimationEventBlock = {animation, animatedObject, playingBackward in
                
                if self.hasCoconut {
                    let worldMtx = self.coconut!.presentation.worldTransform
                    self.coconut!.removeFromParentNode()
                    
                    let node = AAPLCoconut.coconutThrowProtoObject()
                    let coconutPhysicsShape = AAPLCoconut.coconutPhysicsShape
                    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: coconutPhysicsShape)
                    node.physicsBody!.restitution = 0.9
                    node.physicsBody!.collisionBitMask = GameCollisionCategoryPlayer | GameCollisionCategoryGround
                    if #available(iOS 9.0, OSX 10.11, *) {
                        node.physicsBody!.contactTestBitMask = node.physicsBody!.collisionBitMask
                    }
                    node.physicsBody!.categoryBitMask = GameCollisionCategoryCoconut
                    
                    node.transform = worldMtx
                    AAPLGameSimulation.sim.rootNode.addChildNode(node)
                    AAPLGameSimulation.sim.gameLevel.coconuts.append(node)
                    node.physicsBody!.applyForce(SCNVector3Make(-200, 500, 300), asImpulse: true)
                    self.hasCoconut = false
                    self.isIdle = true
                }
            }
            throwAnim.animationEvents = [SCNAnimationEvent(keyTime: 0.35, block: throwEventBlock)]
        }
        
        throwAnim.repeatCount = 0
    }
    
    /*! update the Monkey and decide when to throw a coconut
    */
    override func update(_ deltaTime: TimeInterval) {
        var distanceToCharacter = CGFloat.greatestFiniteMagnitude
        let playerCharacter = AAPLGameSimulation.sim.gameLevel.playerCharacter
        
        let pos = AAPLMatrix4GetPosition(self.presentation.worldTransform)
        let myPosition = GLKVector3Make(Float(pos.x), Float(pos.y), Float(pos.z))
        
        // If the player is to the left of the monkey, calculate how far away the character is.
        if (playerCharacter?.position.x ?? 0.0) < SCNVectorFloat(myPosition.x) {
            distanceToCharacter = CGFloat(GLKVector3Distance(SCNVector3ToGLKVector3(playerCharacter!.position), myPosition))
        }
        
        // If the character is close enough and not moving, throw a coconut.
        if distanceToCharacter < 700 {
            if isIdle {
                if playerCharacter?.running ?? false {
                    self.mainSkeleton?.addAnimation(self.cachedAnimationForKey("monkey_get_coconut-1")!, forKey: nil)
                    isIdle = false
                } else {
                    // taunt the player if they aren't moving.
                    if AAPLRandomPercent() <= 0.001 {
                        isIdle = false
                        self.self.mainSkeleton?.addAnimation(self.cachedAnimationForKey("monkey_tree_hang_taunt-1")!, forKey: nil)
                    }
                }
            }
            
        }
    }
    
}
