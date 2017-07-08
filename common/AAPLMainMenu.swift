//
//  AAPLMainMenu.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/23.
//  Copyright © 2015 Apple Inc. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A Sprite Kit node that provides the title screen for the game, displayed by the AAPLInGameScene class.

 */

import SpriteKit

@objc(AAPLMainMenu)
class AAPLMainMenu: SKNode {
    
    private var gameLogo: SKSpriteNode
    //private var myLabelBackground: SKLabelNode? //### not used
    
    init(size frameSize: CGSize) {
        self.gameLogo = SKSpriteNode(imageNamed: "art.scnassets/level/interface/logo_bananas.png")
        super.init()
        
        self.position = CGPoint(x: frameSize.width * 0.5, y: frameSize.height * 0.15)
        self.isUserInteractionEnabled = true
        
        // resize logo to fit the screen
        var size = self.gameLogo.size
        let factor = frameSize.width / size.width
        size.width *= factor
        size.height *= factor
        self.gameLogo.size = size
        
        self.gameLogo.anchorPoint = CGPoint(x: 1, y: 0)
        self.gameLogo.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(self.gameLogo)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpAtPoint(_ location: CGPoint) {
        self.isHidden = true
        AAPLGameSimulation.sim.gameState = .inGame
    }
    
}
