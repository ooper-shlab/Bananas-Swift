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
    
    var virtialDPadRect: CGRect = CGRect(x: 0, y: 0, width: 0.5, height: 1)
    var virtualDPadWalkThreshold: CGFloat = 20
    var virtualDPadRunThreshold: CGFloat = 40
    
    var buttonARect: CGRect = CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
    
    private var _dpadTouch: UITouch?
    private var _originalLocation: CGPoint = CGPoint()
    private var _buttonATouch: UITouch?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        self.virtialDPadRect = CGRect(x: 0, y: 0, width: 0.5, height: 1)
        self.buttonARect = CGRect(x: 0.5, y: 0, width: 0.5, height: 1)
        self.virtualDPadWalkThreshold = 20
        self.virtualDPadRunThreshold = 40
    }
    
    private func touch(_ touch: UITouch, isInRect _rect: CGRect) -> Bool {
        let bounds = self.view!.bounds
        var rect = _rect
        rect = rect.applying(CGAffineTransform(scaleX: bounds.size.width, y: bounds.size.height))
        return rect.contains(touch.location(in: self.view))
    }
    
    override func reset() {
        _buttonATouch = nil
        _dpadTouch = _buttonATouch
        self.leftPressed = false
        self.rightPressed = false
        self.buttonAPressed = false
        super.reset()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            if _dpadTouch == nil && self.touch(touch, isInRect: self.virtialDPadRect) {
                _dpadTouch = touch
                _originalLocation = touch.location(in: self.view)
                self.state = .began
            } else if _buttonATouch == nil && self.touch(touch, isInRect: self.buttonARect) {
                _buttonATouch = touch
                self.buttonAPressed = true
                self.state = .began
            } else {
                self.ignore(touch, for: event)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        for touch in touches {
            if touch === _dpadTouch {
                let location = touch.location(in: self.view)
                let deltaX = location.x - _originalLocation.x
                self.leftPressed = (deltaX < -self.virtualDPadWalkThreshold)
                self.rightPressed = (deltaX > self.virtualDPadWalkThreshold)
                self.running = abs(deltaX) > self.virtualDPadRunThreshold
                self.state = .changed
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
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
                self.state = .changed
            } else {
                self.state = .cancelled
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
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
                self.state = .changed
            } else {
                self.state = .ended
            }
        }
    }
    
}
