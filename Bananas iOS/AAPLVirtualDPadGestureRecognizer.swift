//
//  AAPLVirtualDPadGestureRecognizer.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/21.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A gesture recognizer that emulates a game controller. Slide left or right on the left half of the screen to move the character, and tap on the right half of the screen to jump.

 */

import UIKit
import UIKit.UIGestureRecognizerSubclass

@objc(AAPLVirtualDPadGestureRecognizer)
class AAPLVirtualDPadGestureRecognizer : UIGestureRecognizer {
    
    var leftPressed: Bool = false
    var rightPressed: Bool = false
    var running: Bool = false
    
    var buttonAPressed: Bool = false
    
    var virtialDPadRect: CGRect = CGRectMake(0, 0, 0.5, 1)
    var virtualDPadWalkThreshold: CGFloat = 20
    var virtualDPadRunThreshold: CGFloat = 40
    
    var buttonARect: CGRect = CGRectMake(0.5, 0, 0.5, 1)
    
    private var _dpadTouch: UITouch?
    private var _originalLocation: CGPoint = CGPoint()
    private var _buttonATouch: UITouch?
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        self.virtialDPadRect = CGRectMake(0, 0, 0.5, 1)
        self.buttonARect = CGRectMake(0.5, 0, 0.5, 1)
        self.virtualDPadWalkThreshold = 20
        self.virtualDPadRunThreshold = 40
    }
    
    private func touch(touch: UITouch, isInRect _rect: CGRect) -> Bool {
        let bounds = self.view!.bounds
        var rect = _rect
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(bounds.size.width, bounds.size.height))
        return CGRectContainsPoint(rect, touch.locationInView(self.view))
    }
    
    override func reset() {
        _buttonATouch = nil
        _dpadTouch = _buttonATouch
        self.leftPressed = false
        self.rightPressed = false
        self.buttonAPressed = false
        super.reset()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        for touch in touches {
            if _dpadTouch == nil && self.touch(touch, isInRect: self.virtialDPadRect) {
                _dpadTouch = touch
                _originalLocation = touch.locationInView(self.view)
                self.state = .Began
            } else if _buttonATouch == nil && self.touch(touch, isInRect: self.buttonARect) {
                _buttonATouch = touch
                self.buttonAPressed = true
                self.state = .Began
            } else {
                self.ignoreTouch(touch, forEvent: event)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        for touch in touches {
            if touch === _dpadTouch {
                let location = touch.locationInView(self.view)
                let deltaX = location.x - _originalLocation.x
                self.leftPressed = (deltaX < -self.virtualDPadWalkThreshold)
                self.rightPressed = (deltaX > self.virtualDPadWalkThreshold)
                self.running = abs(deltaX) > self.virtualDPadRunThreshold
                self.state = .Changed
            }
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        if _dpadTouch != nil || _buttonATouch != nil {
            for touch in touches {
                if touch === _dpadTouch {
                    _dpadTouch = nil
                    self.leftPressed = false
                    self.rightPressed = false
                } else if touch === _buttonATouch {
                    _buttonATouch = nil
                    self.buttonAPressed = false
                }
            }
            if _dpadTouch != nil || _buttonATouch != nil {
                self.state = .Changed
            } else {
                self.state = .Cancelled
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        if _dpadTouch != nil || _buttonATouch != nil {
            for touch in touches {
                if touch === _dpadTouch {
                    _dpadTouch = nil
                    self.rightPressed = false
                    self.leftPressed = false
                } else if touch === _buttonATouch {
                    _buttonATouch = nil
                    self.buttonAPressed = false
                }
            }
            if _dpadTouch != nil || _buttonATouch != nil {
                self.state = .Changed
            } else {
                self.state = .Ended
            }
        }
    }
    
}