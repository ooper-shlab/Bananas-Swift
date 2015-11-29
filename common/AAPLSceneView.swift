//
//  AAPLSceneView.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/22.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The view displaying the game scene. Handles keyboard (OS X) and touch (iOS) input for controlling the game, and forwards other click/touch events to the SpriteKit overlay UI.

 */

import SceneKit

let AAPLLeftKey = "AAPLLeftKey"
let AAPLRightKey = "AAPLRightKey"
let AAPLJumpKey = "AAPLJumpKey"
let AAPLRunKey = "AAPLRunKey"

@objc(AAPLSceneView)
class AAPLSceneView: SCNView {

    var keysPressed: Set<String> = []

// Keyspressed is our set of current inputs
    private func updateKey(key: String, isPressed: Bool) {
        if isPressed {
            self.keysPressed.insert(key)
        } else {
            self.keysPressed.remove(key)
        }
    }

    #if os(iOS)

    init() {
        super.init(frame: CGRect(), options: nil)
//	if (self) {
//		AAPLVirtualDPadGestureRecognizer *gesture = [[AAPLVirtualDPadGestureRecognizer alloc] initWithTarget:self action:@selector(handleVirtualDPadAction:)];
//		gesture.delegate = self;
//		[self addGestureRecognizer:gesture];
        self.setupGestureRecognizer()
//	}
//	return self;
//}
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupGestureRecognizer()
    }
    private func setupGestureRecognizer() {
        let gesture = AAPLVirtualDPadGestureRecognizer(target: self, action: "handleVirtualDPadAction:")
        gesture.delegate = self
        self.addGestureRecognizer(gesture)
    }
//
//- (void)handleVirtualDPadAction:(AAPLVirtualDPadGestureRecognizer *)gesture
//{
    @objc func handleVirtualDPadAction(gesture: AAPLVirtualDPadGestureRecognizer) {
//	[self updateKey:AAPLLeftKey isPressed:gesture.leftPressed];
        self.updateKey(AAPLLeftKey, isPressed: gesture.leftPressed)
//	[self updateKey:AAPLRightKey isPressed:gesture.rightPressed];
        self.updateKey(AAPLRightKey, isPressed: gesture.rightPressed)
//	[self updateKey:AAPLRunKey isPressed:gesture.running];
        self.updateKey(AAPLRunKey, isPressed: gesture.running)
//	[self updateKey:AAPLJumpKey isPressed:gesture.buttonAPressed];
        self.updateKey(AAPLJumpKey, isPressed: gesture.buttonAPressed)
//}
    }
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//	if (self.scene) {
        if self.scene != nil {
//		return [AAPLGameSimulation sim].gameState == AAPLGameStateInGame;
            return AAPLGameSimulation.sim.gameState == .InGame
//	}
        }
//	return NO;
        return false
//}
    }
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//	AAPLInGameScene *skScene = (AAPLInGameScene *)self.overlaySKScene;
        let skScene = self.overlaySKScene as! AAPLInGameScene
//	UITouch *touch = [touches anyObject];
        let touch = touches.first!
//	CGPoint p = [touch locationInNode:skScene];
        let p = touch.locationInNode(skScene)
//	[skScene touchUpAtPoint:p];
        skScene.touchUpAtPoint(p)
//	[super touchesEnded:touches withEvent:event];
        super.touchesEnded(touches, withEvent: event)
//}
    }
//
//#else
    #else

    override func keyDown(theEvent: NSEvent) {

        let keyHit = theEvent.characters?.utf16.first ?? 0


        if theEvent.modifierFlags.contains(.ShiftKeyMask) {
            self.updateKey(AAPLRunKey, isPressed: true)
        }

        switch keyHit {
        case UInt16(NSRightArrowFunctionKey):
            self.updateKey(AAPLRightKey, isPressed: true)
        case UInt16(NSLeftArrowFunctionKey):
            self.updateKey(AAPLLeftKey, isPressed: true)
        case "r":
            self.updateKey(AAPLRunKey, isPressed: true)
        case " ":
            self.updateKey(AAPLJumpKey, isPressed: true)
        default:
            break
        }

        super.keyDown(theEvent)
    }

    override func keyUp(theEvent: NSEvent) {

        let keyReleased = theEvent.characters?.utf16.first ?? 0

        switch keyReleased {
        case UInt16(NSRightArrowFunctionKey):
            self.updateKey(AAPLRightKey, isPressed: false)
        case UInt16(NSLeftArrowFunctionKey):
            self.updateKey(AAPLLeftKey, isPressed: false)
        case "r":
            self.updateKey(AAPLRunKey, isPressed: false)
        case " ":
            self.updateKey(AAPLJumpKey, isPressed: false)
        default:
            break
        }

        if theEvent.modifierFlags.contains(.ShiftKeyMask) {
            self.updateKey(AAPLRunKey, isPressed: false)
        }
    }

    override func mouseUp(event: NSEvent) {
        let skScene = self.overlaySKScene as! AAPLInGameScene
        let p = skScene.convertPointFromView(event.locationInWindow)
        skScene.touchUpAtPoint(p)

        super.mouseUp(event)
    }

    #endif

}
#if os(iOS)
    extension AAPLSceneView: UIGestureRecognizerDelegate {}
#endif
