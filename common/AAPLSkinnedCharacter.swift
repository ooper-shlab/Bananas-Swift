//
//  AAPLSkinnedCharacter.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/21.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  This class manages loading and running skeletal animations for a character in the game.

 */

import SceneKit

@objc(AAPLSkinnedCharacter)
class AAPLSkinnedCharacter: SCNNode, CAAnimationDelegate {
    
    // Dictionary used to look up the animations by key.
    var animationsDict: [String: CAAnimation] = [:]
    
    // main skeleton reference for faster look up.
    var mainSkeleton: SCNNode?
    
    func findAndSetSkeleton() {
        self.enumerateChildNodes {child, stop in
            if child.skinner != nil {
                self.mainSkeleton = child.skinner!.skeleton
                stop.pointee = true
            }
        }
    }
    
    init(node characterRootNode: SCNNode) {
        super.init()
        characterRootNode.position = SCNVector3Make(0, 0, 0)
        
        self.addChildNode(characterRootNode)
        
        //-- Find the first skeleton
        self.enumerateChildNodes {child, stop in
            if child.skinner != nil {
                self.mainSkeleton = child.skinner!.skeleton
                stop.pointee = true
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cachedAnimationForKey(_ key: String) -> CAAnimation? {
        return self.animationsDict[key]
    }
    
    class func loadAnimationNamed(_ animationName: String, fromSceneNamed sceneName: String) -> CAAnimation? {
        // Load the DAE using SCNSceneSource in order to be able to retrieve the animation by its identifier
        let url = Bundle.main.url(forResource: sceneName, withExtension: "dae")!
        #if os(OSX)
            let options: [SCNSceneSource.LoadingOption: Any] = [SCNSceneSource.LoadingOption.convertToYUp: true]
        #else
            let options: [SCNSceneSource.LoadingOption: Any] = [:]
        #endif
        let sceneSource = SCNSceneSource(url: url, options: options)
        
        let animation = sceneSource?.entryWithIdentifier(animationName, withClass: CAAnimation.self)
        
        // Blend animations for smoother transitions
        animation?.fadeInDuration = 0.3
        animation?.fadeOutDuration = 0.3
        
        return animation
    }
    
    func loadAndCacheAnimation(_ daeFile: String, withName name: String, forKey key: String) -> CAAnimation? {
        
        let anim = type(of: self).loadAnimationNamed(name, fromSceneNamed: daeFile)
        
        if anim != nil {
            self.animationsDict[key] = anim!
            anim!.delegate = self
        }
        return anim
    }
    
    func loadAndCacheAnimation(_ daeFile: String, forKey key: String) -> CAAnimation? {
        return self.loadAndCacheAnimation(daeFile, withName: key, forKey: key)
    }
    
    func chainAnimation(_ firstKey: String, toAnimation secondKey: String) {
        self.chainAnimation(firstKey, toAnimation: secondKey, fadeTime: 0.85)
    }
    
    func chainAnimation(_ firstKey: String, toAnimation secondKey: String, fadeTime: CGFloat) {
        guard let
            firstAnim = self.cachedAnimationForKey(firstKey),
            let secondAnim = self.cachedAnimationForKey(secondKey)
            else {
                return
        }
        
        let chainEventBlock: SCNAnimationEventBlock = {animation, animatedObject, playingBackward in
            self.mainSkeleton?.addAnimation(secondAnim, forKey: secondKey)
        }
        
        if firstAnim.animationEvents == nil || firstAnim.animationEvents!.count == 0 {
            firstAnim.animationEvents = [SCNAnimationEvent(keyTime: fadeTime, block: chainEventBlock)]
        } else {
            var pastEvents = firstAnim.animationEvents
            pastEvents?.append(SCNAnimationEvent(keyTime: fadeTime, block: chainEventBlock))
            firstAnim.animationEvents = pastEvents
        }
    }
    
    func update(_ deltaTime: TimeInterval) {
        // To be implemented by subclasses
    }
    
}
