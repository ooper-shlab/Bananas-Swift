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
    var gameState: AAPLGameState = .preGame {
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
        self.timeLabel.position = CGPoint(x: self.frame.size.width - af.size.width, y: self.frame.size.height - (af.size.height))
        
        self.addChild(timeLabelValue)
        let timeLabelValueSize = timeLabelValue.calculateAccumulatedFrame()
        timeLabelValue.position = CGPoint(x: self.frame.size.width - af.size.width - timeLabelValueSize.size.width - 10, y: self.frame.size.height - (af.size.height))
        
        self.addChild(self.scoreLabel)
        af = self.scoreLabel.calculateAccumulatedFrame()
        self.scoreLabel.position = CGPoint(x: af.size.width * 0.5, y: self.frame.size.height - (af.size.height))
        
        self.addChild(scoreLabelValue)
        scoreLabelValue.position = CGPoint(x: af.size.width * 0.75 + (timeLabelValueSize.size.width), y: self.frame.size.height - (af.size.height))
        
        // Add drop shadows to each label above.
        self.timeLabelValueShadow = AAPLInGameScene.dropShadowOnLabel(timeLabelValue)
        self.scoreLabelShadow = AAPLInGameScene.dropShadowOnLabel(self.scoreLabel)
        self.timeLabelShadow = AAPLInGameScene.dropShadowOnLabel(self.timeLabel)
        self.scoreLabelValueShadow = AAPLInGameScene.dropShadowOnLabel(scoreLabelValue)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func willSetGameState(_ newState: AAPLGameState) {
        
        self.menuNode?.removeFromParent()
        self.pauseNode?.removeFromParent()
        self.postGameNode?.removeFromParent()
        
        switch newState {
        case .preGame:
            self.menuNode = AAPLMainMenu(size: self.frame.size)
            self.addChild(self.menuNode!)
        case .inGame:
            self.hideInGameUI(false)
        case .paused:
            self.pauseNode = AAPLPauseMenu(size: self.frame.size)
            self.addChild(self.pauseNode!)
        case .postGame:
            self.postGameNode = AAPLPostGameMenu(size: self.frame.size, andDelegate: self.gameStateDelegate)
            self.addChild(self.postGameNode!)
            self.hideInGameUI(true)
        }
        
    }
    
    private func hideInGameUI(_ hide: Bool) {
        self.scoreLabelValue.isHidden = hide
        self.scoreLabelValueShadow.isHidden = hide
        self.timeLabelValue.isHidden = hide
        self.timeLabelValueShadow.isHidden = hide
        self.scoreLabel.isHidden = hide
        self.scoreLabelShadow.isHidden = hide
        self.timeLabel.isHidden = hide
        self.timeLabelShadow.isHidden = hide
    }
    
    class func labelWithText(_ text: String, andSize textSize: CGFloat) -> SKLabelNode {
        let fontName = "Optima-ExtraBlack"
        let myLabel = SKLabelNode(fontNamed: fontName)
        
        myLabel.text = text
        myLabel.fontSize = textSize
        myLabel.fontColor = SKColor.yellow
        
        return myLabel
    }
    
    @discardableResult class func dropShadowOnLabel(_ frontLabel: SKLabelNode) -> SKLabelNode {
        let myLabelBackground = frontLabel.copy() as! SKLabelNode
        myLabelBackground.isUserInteractionEnabled = false
        myLabelBackground.fontColor = SKColor.black
        myLabelBackground.position = CGPoint(x: 2 + frontLabel.position.x, y: -2 + frontLabel.position.y)
        
        myLabelBackground.zPosition = frontLabel.zPosition - 1
        frontLabel.parent?.addChild(myLabelBackground)
        return myLabelBackground
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update the score and time labels with the correct data.
        self.gameStateDelegate?.scoreLabelLocation = self.scoreLabelValue.position
        
        scoreLabelValue.text = String(self.gameStateDelegate?.score ?? 0)
        scoreLabelValueShadow.text = scoreLabelValue.text
        
        let minutes = Int((self.gameStateDelegate?.secondsRemaining ?? 0) / 60.0)
        let seconds = Int(fmod(self.gameStateDelegate?.secondsRemaining ?? 0, 60.0))
        timeLabelValue.text = String(format: "%lu:%02lu", minutes, seconds)
        self.timeLabelValueShadow.text = timeLabelValue.text
    }
    
    func touchUpAtPoint(_ location: CGPoint) {
        switch gameState {
        case .paused:
            self.pauseNode?.touchUpAtPoint(location)
        case .postGame:
            self.postGameNode?.touchUpAtPoint(location)
        case .preGame:
            self.menuNode?.touchUpAtPoint(location)
        case .inGame:
            let touchedNode = self.scene?.atPoint(location)
            
            if touchedNode === self.timeLabelValue {
                AAPLGameSimulation.sim.gameState = .paused
            }
        }
    }
    
}
