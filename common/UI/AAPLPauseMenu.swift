//
//  AAPLPauseMenu.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/23.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A Sprite Kit node that provides the pause screen for the game, displayed by the AAPLInGameScene class.

 */

import SpriteKit

@objc(AAPLPauseMenu)
class AAPLPauseMenu: SKNode {
    
    private var myLabel: SKLabelNode
    
    init(size frameSize: CGSize) {
        self.myLabel = AAPLInGameScene.labelWithText("Resume", andSize: 65)
        super.init()
        
        self.myLabel.position = CGPoint(x: self.frame.midX,
            y: self.frame.midY)
        
        self.position = CGPoint(x: frameSize.width * 0.5, y: frameSize.height * 0.5)
        
        self.addChild(self.myLabel)
        
        AAPLInGameScene.dropShadowOnLabel(self.myLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpAtPoint(_ location: CGPoint) {
        let touchedNode = self.scene?.atPoint(location)
        
        if touchedNode === self.myLabel {
            self.isHidden = true
            AAPLGameSimulation.sim.gameState = .inGame
        }
    }
    
}
