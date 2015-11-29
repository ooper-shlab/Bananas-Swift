//
//  AAPLInGameScene.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/22.
//  Copyright © 2015 Apple Inc. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A Sprite Kit scene that provides the 2D overlay UI for the game, and displays different child nodes for title, pause, and post-game screens.

 */

import SpriteKit

@objc(AAPLInGameScene)
class AAPLInGameScene: SKScene {
    
    
    var scoreLabelValue: SKLabelNode
    var scoreLabelValueShadow: SKLabelNode!
    var gameState: AAPLGameState = .PreGame {
        willSet {
            willSetGameState(newValue)
        }
    }
    var gameStateDelegate: AAPLGameUIState?
    
    private var timeLabelValue: SKLabelNode
    private var timeLabelValueShadow: SKLabelNode!
    private var scoreLabel: SKLabelNode
    private var scoreLabelShadow: SKLabelNode!
    private var timeLabel: SKLabelNode
    private var timeLabelShadow: SKLabelNode!
    private var menuNode: AAPLMainMenu?
    private var pauseNode: AAPLPauseMenu?
    private var postGameNode: AAPLPostGameMenu?
    
    override init(size: CGSize) {
        self.timeLabel = AAPLInGameScene.labelWithText("Time", andSize: 24)
        timeLabelValue = AAPLInGameScene.labelWithText("102:00", andSize: 20)
        self.scoreLabel = AAPLInGameScene.labelWithText("Score", andSize: 24)
        scoreLabelValue = AAPLInGameScene.labelWithText("0", andSize: 24)
        super.init(size: size)
        
        self.backgroundColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1)
        
        self.addChild(self.timeLabel)
        var af = self.timeLabel.calculateAccumulatedFrame()
        self.timeLabel.position = CGPointMake(self.frame.size.width - af.size.width, self.frame.size.height - (af.size.height))
        
        self.addChild(timeLabelValue)
        let timeLabelValueSize = timeLabelValue.calculateAccumulatedFrame()
        timeLabelValue.position = CGPointMake(self.frame.size.width - af.size.width - timeLabelValueSize.size.width - 10, self.frame.size.height - (af.size.height))
        
        self.addChild(self.scoreLabel)
        af = self.scoreLabel.calculateAccumulatedFrame()
        self.scoreLabel.position = CGPointMake(af.size.width * 0.5, self.frame.size.height - (af.size.height))
        
        self.addChild(scoreLabelValue)
        scoreLabelValue.position = CGPointMake(af.size.width * 0.75 + (timeLabelValueSize.size.width), self.frame.size.height - (af.size.height))
        
        // Add drop shadows to each label above.
        self.timeLabelValueShadow = AAPLInGameScene.dropShadowOnLabel(timeLabelValue)
        self.scoreLabelShadow = AAPLInGameScene.dropShadowOnLabel(self.scoreLabel)
        self.timeLabelShadow = AAPLInGameScene.dropShadowOnLabel(self.timeLabel)
        self.scoreLabelValueShadow = AAPLInGameScene.dropShadowOnLabel(scoreLabelValue)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func willSetGameState(newState: AAPLGameState) {
        
        self.menuNode?.removeFromParent()
        self.pauseNode?.removeFromParent()
        self.postGameNode?.removeFromParent()
        
        switch newState {
        case .PreGame:
            self.menuNode = AAPLMainMenu(size: self.frame.size)
            self.addChild(self.menuNode!)
        case .InGame:
            self.hideInGameUI(false)
        case .Paused:
            self.pauseNode = AAPLPauseMenu(size: self.frame.size)
            self.addChild(self.pauseNode!)
        case .PostGame:
            self.postGameNode = AAPLPostGameMenu(size: self.frame.size, andDelegate: self.gameStateDelegate)
            self.addChild(self.postGameNode!)
            self.hideInGameUI(true)
        }
        
    }
    
    private func hideInGameUI(hide: Bool) {
        self.scoreLabelValue.hidden = hide
        self.scoreLabelValueShadow.hidden = hide
        self.timeLabelValue.hidden = hide
        self.timeLabelValueShadow.hidden = hide
        self.scoreLabel.hidden = hide
        self.scoreLabelShadow.hidden = hide
        self.timeLabel.hidden = hide
        self.timeLabelShadow.hidden = hide
    }
    
    class func labelWithText(text: String, andSize textSize: CGFloat) -> SKLabelNode {
        let fontName = "Optima-ExtraBlack"
        let myLabel = SKLabelNode(fontNamed: fontName)
        
        myLabel.text = text
        myLabel.fontSize = textSize
        myLabel.fontColor = SKColor.yellowColor()
        
        return myLabel
    }
    
    class func dropShadowOnLabel(frontLabel: SKLabelNode) -> SKLabelNode {
        let myLabelBackground = frontLabel.copy() as! SKLabelNode
        myLabelBackground.userInteractionEnabled = false
        myLabelBackground.fontColor = SKColor.blackColor()
        myLabelBackground.position = CGPointMake(2 + frontLabel.position.x, -2 + frontLabel.position.y)
        
        myLabelBackground.zPosition = frontLabel.zPosition - 1
        frontLabel.parent?.addChild(myLabelBackground)
        return myLabelBackground
    }
    
    override func update(currentTime: NSTimeInterval) {
        // Update the score and time labels with the correct data.
        self.gameStateDelegate?.scoreLabelLocation = self.scoreLabelValue.position
        
        scoreLabelValue.text = String(self.gameStateDelegate?.score ?? 0)
        scoreLabelValueShadow.text = scoreLabelValue.text
        
        let minutes = Int((self.gameStateDelegate?.secondsRemaining ?? 0) / 60.0)
        let seconds = Int(fmod(self.gameStateDelegate?.secondsRemaining ?? 0, 60.0))
        timeLabelValue.text = String(format: "%lu:%02lu", minutes, seconds)
        self.timeLabelValueShadow.text = timeLabelValue.text
    }
    
    func touchUpAtPoint(location: CGPoint) {
        switch gameState {
        case .Paused:
            self.pauseNode?.touchUpAtPoint(location)
        case .PostGame:
            self.postGameNode?.touchUpAtPoint(location)
        case .PreGame:
            self.menuNode?.touchUpAtPoint(location)
        case .InGame:
            let touchedNode = self.scene?.nodeAtPoint(location)
            
            if touchedNode === self.timeLabelValue {
                AAPLGameSimulation.sim.gameState = .Paused
            }
        }
    }
    
}