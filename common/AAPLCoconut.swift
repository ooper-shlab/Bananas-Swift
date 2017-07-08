//
//  AAPLCoconut.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/21.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  This class manages the coconuts thrown by monkeys in the game. It configures and vends instances for use by the AAPLMonkeyCharacter class, which uses them both for simple animation (the monkey retrieving a coconut from the tree) and physics simulation (the monkey throwing a coconut at the player).

 */

import SceneKit

import GLKit

// AAPLCoconut
//
// Coconut object that hold simulation information
//
@objc(AAPLCoconut)
class AAPLCoconut: SCNNode {
    
    static let coconutPhysicsShape: SCNPhysicsShape = {
        
        let sphere = SCNSphere(radius: 25)
        return SCNPhysicsShape(geometry: sphere, options: nil)
        
    }()
    
    class func coconutProtoObject() -> SCNNode {
        struct s {
            static var coconutProtoObject: SCNNode = {
                
                let coconutDaeName = AAPLGameSimulation.pathForArtResource("characters/monkey/coconut.dae")
                return AAPLGameSimulation.loadNodeWithName("Coconut",
                    fromSceneNamed: coconutDaeName)!
            }()
        }
        
        // create and return a clone of our proto object.
        let coconut = s.coconutProtoObject.clone()
        coconut.name = "coconut"
        
        return coconut
    }
    
    class func coconutThrowProtoObject() -> AAPLCoconut {
        struct s {
            static var coconutThrowProtoObject: AAPLCoconut = {
                
                let coconutDaeName = AAPLGameSimulation.pathForArtResource("characters/monkey/coconut_no_translation.dae")
                let node = AAPLGameSimulation.loadNodeWithName("coconut",
                    fromSceneNamed: coconutDaeName)!
                let s_coconutThrowProtoObject = AAPLCoconut()
                s_coconutThrowProtoObject.addChildNode(node)
                
                s_coconutThrowProtoObject.enumerateChildNodes {child, stop in
                    for m in child.geometry?.materials ?? [] {
                        m.lightingModel = SCNMaterial.LightingModel.constant
                    }
                }
                return s_coconutThrowProtoObject
            }()
        }
        
        // create and return a clone of our proto object.
        let coconut = s.coconutThrowProtoObject.clone()
        coconut.name = "coconut_throw"
        return coconut
    }
    
}
