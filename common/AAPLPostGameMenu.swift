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
        let background = SKSpriteNode(color: SKColor.blackColor(),
            size: CGSizeMake(frameSize.width * 0.8, menuHeight))
        background.zPosition = -1
        background.alpha = 0.5
        background.position = CGPointMake(0, -0.2 * menuHeight)
        self.addChild(background)
        
        self.myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
            CGRectGetMidY(self.frame))
        
        self.position = CGPointMake(frameSize.width * 0.5, frameSize.height * 0.5)
        self.userInteractionEnabled = true
        self.myLabel.userInteractionEnabled = true
        self.addChild(self.myLabel)
        AAPLInGameScene.dropShadowOnLabel(self.myLabel)
        
        var      bananaLocation = CGPointMake(frameSize.width * -0.4, CGRectGetMidY(self.frame) * -0.4)
        var	   coinLocation = CGPointMake(frameSize.width * -0.4, CGRectGetMidY(self.frame) * -0.6)
        var       totalLocation = CGPointMake(frameSize.width * -0.4, CGRectGetMidY(self.frame) * -0.8)
        var bananaScoreLocation = CGPointMake(frameSize.width * +0.4, CGRectGetMidY(self.frame) * -0.4)
        var   coinScoreLocation = CGPointMake(frameSize.width * +0.4, CGRectGetMidY(self.frame) * -0.6)
        var  totalScoreLocation = CGPointMake(frameSize.width * +0.4, CGRectGetMidY(self.frame) * -0.8)
        
        self.bananaText = self.myLabel.copy() as! SKLabelNode
        self.bananaText.text = "Bananas"
        self.bananaText.fontSize = 0.1 * menuHeight
        self.bananaText.setScale(0.8)
        bananaLocation.x += (CGRectGetWidth(self.bananaText.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1
        self.bananaText.position = CGPointMake(bananaLocation.x, -2000)
        self.addChild(self.bananaText)
        AAPLInGameScene.dropShadowOnLabel(self.bananaText)
        
        self.bananaScore = self.bananaText.copy() as! SKLabelNode
        self.bananaScore.text = "000"
        bananaScoreLocation.x -= ((CGRectGetWidth(self.bananaScore.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1)
        self.bananaScore.position = CGPointMake(bananaScoreLocation.x, -2000)
        self.addChild(self.bananaScore)
        
        
        self.coinText = self.bananaText.copy() as! SKLabelNode
        self.coinText.text = "Large Bananas"
        coinLocation.x += (CGRectGetWidth(self.coinText.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1
        self.coinText.position = CGPointMake(coinLocation.x, -2000)
        self.addChild(self.coinText)
        AAPLInGameScene.dropShadowOnLabel(self.coinText)
        
        
        self.coinScore = self.coinText.copy() as! SKLabelNode
        self.coinScore.text = "000"
        coinScoreLocation.x -= ((CGRectGetWidth(self.coinScore.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1)
        self.coinScore.position = CGPointMake(coinScoreLocation.x, -2000)
        self.addChild(self.coinScore)
        
        self.totalText = self.bananaText.copy() as! SKLabelNode
        self.totalText.text = "Total"
        totalLocation.x += (CGRectGetWidth(self.totalText.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1
        self.totalText.position = CGPointMake(totalLocation.x, -2000)
        self.addChild(self.totalText)
        AAPLInGameScene.dropShadowOnLabel(self.totalText)
        
        
        self.totalScore = self.totalText.copy() as! SKLabelNode
        self.totalScore.text = "000"
        totalScoreLocation.x -= ((CGRectGetWidth(self.totalScore.calculateAccumulatedFrame()) * 0.5) + frameSize.width * 0.1)
        self.totalScore.position = CGPointMake(totalScoreLocation.x, -2000)
        self.addChild(self.totalScore)
        
        let flyup = SKAction.moveTo(CGPointMake(frameSize.width * 0.5, frameSize.height - 100), duration: 0.25)
        flyup.timingMode = .EaseInEaseOut
        
        let flyupBananas = SKAction.moveTo(bananaLocation, duration: 0.25)
        let flyupBananasScore = SKAction.moveTo(bananaScoreLocation, duration: 0.25)
        flyupBananas.timingMode = .EaseInEaseOut
        flyupBananasScore.timingMode = .EaseInEaseOut
        
        let flyupCoins = SKAction.moveTo(coinLocation, duration: 0.25)
        let flyupCoinsScore = SKAction.moveTo(coinScoreLocation, duration: 0.25)
        flyupCoins.timingMode = .EaseInEaseOut
        flyupCoinsScore.timingMode = .EaseInEaseOut
        
        let flyupTotal = SKAction.moveTo(totalLocation, duration: 0.25)
        let flyupTotalScore = SKAction.moveTo(totalScoreLocation, duration: 0.25)
        flyupTotal.timingMode = .EaseInEaseOut
        flyupTotalScore.timingMode = .EaseInEaseOut
        
        let bananasCollected = self.gameStateDelegate?.bananasCollected ?? 0
        let coinsCollected = self.gameStateDelegate?.coinsCollected ?? 0
        let totalCollected = bananasCollected + (coinsCollected * 100)
        
        let countUpBananas = SKAction.customActionWithDuration(NSTimeInterval(bananasCollected) / 100.0) {node, elapsedTime in
            if bananasCollected > 0 {
                let label = node as! SKLabelNode
                let total = Int((elapsedTime / (CGFloat(bananasCollected) / 100.0)) * CGFloat(bananasCollected))
                label.text = String(total)
                if total % 10 == 0 {
                    AAPLGameSimulation.sim.playSound("deposit.caf")
                }
                
            }
            
        }
        let countUpCoins = SKAction.customActionWithDuration(NSTimeInterval(coinsCollected) / 100.0) {node, elapsedTime in
            if coinsCollected > 0 {
                let label = node as! SKLabelNode
                let total = Int((elapsedTime / (CGFloat(coinsCollected) / 100.0)) * CGFloat(coinsCollected))
                label.text = String(total)
                if total % 10 == 0 {
                    AAPLGameSimulation.sim.playSound("deposit.caf")
                }
            }
        }
        let countUpTotal = SKAction.customActionWithDuration(NSTimeInterval(totalCollected / 5) / 100.0) {node, elapsedTime in
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
        self.runAction(flyup) {
            //-- fly up the bananas collected.
            self.bananaText.runAction(flyupBananas)
            self.bananaScore.runAction(flyupBananasScore) {
                //-- count!
                self.bananaScore.runAction(countUpBananas) {
                    self.bananaScore.text = String(bananasCollected)
                    self.coinText.runAction(flyupCoins)
                    self.coinScore.runAction(flyupCoinsScore) {
                        //-- count
                        self.coinScore.runAction(countUpCoins) {
                            self.coinScore.text = String(coinsCollected)
                            self.totalText.runAction(flyupTotal)
                            self.totalScore.runAction(flyupTotalScore) {
                                self.totalScore.runAction(countUpTotal) {
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
    
    func touchUpAtPoint(location: CGPoint) {
        let touchedNode = self.scene?.nodeAtPoint(location)
        
        if touchedNode != nil {
            self.hidden = true
            AAPLGameSimulation.sim.gameState = .InGame
        }
    }
    
}