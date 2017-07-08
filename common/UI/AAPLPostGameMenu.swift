//
//  AAPLPostGameMenu.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/23.
//  Copyright © 2015 Apple Inc. All rights reserved.
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A Sprite Kit node that provides the post-game screen for the game, displayed by the AAPLInGameScene class.

 */

import SpriteKit

@objc(AAPLPostGameMenu)
class AAPLPostGameMenu: SKNode {
    
    weak var gameStateDelegate: AAPLGameUIState?
    
    private var myLabel: SKLabelNode
    private var bananaText: SKLabelNode!
    private var bananaScore: SKLabelNode!
    private var coinText: SKLabelNode!
    private var coinScore: SKLabelNode!
    private var totalText: SKLabelNode!
    private var totalScore: SKLabelNode!
    
    init(size frameSize: CGSize, andDelegate gameStateDelegate: AAPLGameUIState?) {
        self.gameStateDelegate = gameStateDelegate
        self.myLabel = AAPLInGameScene.labelWithText("Final Score", andSize: 65)
        super.init()
        
        let menuHeight = frameSize.height * 0.8
        let background = SKSpriteNode(color: SKColor.black,
            size: CGSize(width: frameSize.width * 0.8, height: menuHeight))
        background.zPosition = -1
        background.alpha = 0.5
        background.position = CGPoint(x: 0, y: -0.2 * menuHeight)
        self.addChild(background)
        
        self.myLabel.position = CGPoint(x: self.frame.midX,
            y: self.frame.midY)
        
        self.position = CGPoint(x: frameSize.width * 0.5, y: frameSize.height * 0.5)
        self.isUserInteractionEnabled = true
        self.myLabel.isUserInteractionEnabled = true
        self.addChild(self.myLabel)
        AAPLInGameScene.dropShadowOnLabel(self.myLabel)
        
        var      bananaLocation = CGPoint(x: frameSize.width * -0.4, y: self.frame.midY * -0.4)
        var	   coinLocation = CGPoint(x: frameSize.width * -0.4, y: self.frame.midY * -0.6)
        var       totalLocation = CGPoint(x: frameSize.width * -0.4, y: self.frame.midY * -0.8)
        var bananaScoreLocation = CGPoint(x: frameSize.width * +0.4, y: self.frame.midY * -0.4)
        var   coinScoreLocation = CGPoint(x: frameSize.width * +0.4, y: self.frame.midY * -0.6)
        var  totalScoreLocation = CGPoint(x: frameSize.width * +0.4, y: self.frame.midY * -0.8)
        
        self.bananaText = self.myLabel.copy() as! SKLabelNode
        self.bananaText.text = "Bananas"
        self.bananaText.fontSize = 0.1 * menuHeight
        self.bananaText.setScale(0.8)
        bananaLocation.x += (self.bananaText.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1
        self.bananaText.position = CGPoint(x: bananaLocation.x, y: -2000)
        self.addChild(self.bananaText)
        AAPLInGameScene.dropShadowOnLabel(self.bananaText)
        
        self.bananaScore = self.bananaText.copy() as! SKLabelNode
        self.bananaScore.text = "000"
        bananaScoreLocation.x -= ((self.bananaScore.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1)
        self.bananaScore.position = CGPoint(x: bananaScoreLocation.x, y: -2000)
        self.addChild(self.bananaScore)
        
        
        self.coinText = self.bananaText.copy() as! SKLabelNode
        self.coinText.text = "Large Bananas"
        coinLocation.x += (self.coinText.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1
        self.coinText.position = CGPoint(x: coinLocation.x, y: -2000)
        self.addChild(self.coinText)
        AAPLInGameScene.dropShadowOnLabel(self.coinText)
        
        
        self.coinScore = self.coinText.copy() as! SKLabelNode
        self.coinScore.text = "000"
        coinScoreLocation.x -= ((self.coinScore.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1)
        self.coinScore.position = CGPoint(x: coinScoreLocation.x, y: -2000)
        self.addChild(self.coinScore)
        
        self.totalText = self.bananaText.copy() as! SKLabelNode
        self.totalText.text = "Total"
        totalLocation.x += (self.totalText.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1
        self.totalText.position = CGPoint(x: totalLocation.x, y: -2000)
        self.addChild(self.totalText)
        AAPLInGameScene.dropShadowOnLabel(self.totalText)
        
        
        self.totalScore = self.totalText.copy() as! SKLabelNode
        self.totalScore.text = "000"
        totalScoreLocation.x -= ((self.totalScore.calculateAccumulatedFrame().width * 0.5) + frameSize.width * 0.1)
        self.totalScore.position = CGPoint(x: totalScoreLocation.x, y: -2000)
        self.addChild(self.totalScore)
        
        let flyup = SKAction.move(to: CGPoint(x: frameSize.width * 0.5, y: frameSize.height - 100), duration: 0.25)
        flyup.timingMode = .easeInEaseOut
        
        let flyupBananas = SKAction.move(to: bananaLocation, duration: 0.25)
        let flyupBananasScore = SKAction.move(to: bananaScoreLocation, duration: 0.25)
        flyupBananas.timingMode = .easeInEaseOut
        flyupBananasScore.timingMode = .easeInEaseOut
        
        let flyupCoins = SKAction.move(to: coinLocation, duration: 0.25)
        let flyupCoinsScore = SKAction.move(to: coinScoreLocation, duration: 0.25)
        flyupCoins.timingMode = .easeInEaseOut
        flyupCoinsScore.timingMode = .easeInEaseOut
        
        let flyupTotal = SKAction.move(to: totalLocation, duration: 0.25)
        let flyupTotalScore = SKAction.move(to: totalScoreLocation, duration: 0.25)
        flyupTotal.timingMode = .easeInEaseOut
        flyupTotalScore.timingMode = .easeInEaseOut
        
        let bananasCollected = self.gameStateDelegate?.bananasCollected ?? 0
        let coinsCollected = self.gameStateDelegate?.coinsCollected ?? 0
        let totalCollected = bananasCollected + (coinsCollected * 100)
        
        let countUpBananas = SKAction.customAction(withDuration: TimeInterval(bananasCollected) / 100.0) {node, elapsedTime in
            if bananasCollected > 0 {
                let label = node as! SKLabelNode
                let total = Int((elapsedTime / (CGFloat(bananasCollected) / 100.0)) * CGFloat(bananasCollected))
                label.text = String(total)
                if total % 10 == 0 {
                    AAPLGameSimulation.sim.playSound("deposit.caf")
                }
                
            }
            
        }
        let countUpCoins = SKAction.customAction(withDuration: TimeInterval(coinsCollected) / 100.0) {node, elapsedTime in
            if coinsCollected > 0 {
                let label = node as! SKLabelNode
                let total = Int((elapsedTime / (CGFloat(coinsCollected) / 100.0)) * CGFloat(coinsCollected))
                label.text = String(total)
                if total % 10 == 0 {
                    AAPLGameSimulation.sim.playSound("deposit.caf")
                }
            }
        }
        let countUpTotal = SKAction.customAction(withDuration: TimeInterval(totalCollected / 5) / 100.0) {node, elapsedTime in
            if totalCollected > 0 {
                let label = node as! SKLabelNode
                let total = Int((elapsedTime / (CGFloat(totalCollected / 5) / 100.0)) * CGFloat(totalCollected))
                label.text = String(total)
                if total % 25 == 0 {
                    AAPLGameSimulation.sim.playSound("deposit.caf")
                }
            }
        }
        
        // Play actions in sequence: Fly up, count up. repeat with the next line.
        self.run(flyup) {
            //-- fly up the bananas collected.
            self.bananaText.run(flyupBananas)
            self.bananaScore.run(flyupBananasScore) {
                //-- count!
                self.bananaScore.run(countUpBananas) {
                    self.bananaScore.text = String(bananasCollected)
                    self.coinText.run(flyupCoins)
                    self.coinScore.run(flyupCoinsScore) {
                        //-- count
                        self.coinScore.run(countUpCoins) {
                            self.coinScore.text = String(coinsCollected)
                            self.totalText.run(flyupTotal)
                            self.totalScore.run(flyupTotalScore) {
                                self.totalScore.run(countUpTotal) {
                                    self.totalScore.text = String(totalCollected)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func touchUpAtPoint(_ location: CGPoint) {
        let touchedNode = self.scene?.atPoint(location)
        
        if touchedNode != nil {
            self.isHidden = true
            AAPLGameSimulation.sim.gameState = .inGame
        }
    }
    
}
