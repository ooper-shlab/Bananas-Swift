//
//  AAPLAppDelegate.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/22.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The shared implementation of the application delegate for both iOS and OS X versions of the game. This class handles initial setup of the game, including loading assets and checking for game controllers, before passing control to AAPLGameSimulation to start the game.

 */

import SceneKit
import SpriteKit
import GameKit

@objc(AAPLAppDelegate)
class AAPLAppDelegate: NSObject {

    @IBOutlet weak var scnView: AAPLSceneView!

    class func sharedAppDelegate() -> AAPLAppDelegate {
        #if os(iOS)
//	return [UIApplication sharedApplication].delegate;
            return UIApplication.sharedApplication().delegate as! AAPLAppDelegate
        #else
            return NSApp.delegate as! AAPLAppDelegate
        #endif
    }

    private func listenForGameControllerWithSim(gameSim: AAPLGameSimulation) {
	//-- GameController hook up
        NSNotificationCenter.defaultCenter().addObserver(gameSim,
            selector: #selector(AAPLGameSimulation.controllerDidConnect),
            name: GCControllerDidConnectNotification,
            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(gameSim,
            selector: #selector(AAPLGameSimulation.controllerDidDisconnect),
            name: GCControllerDidDisconnectNotification,
            object: nil)

        GCController.startWirelessControllerDiscoveryWithCompletionHandler(nil)
    }

    func togglePaused() {
        let currentState = AAPLGameSimulation.sim.gameState

        if currentState == .Paused {
            AAPLGameSimulation.sim.gameState = .InGame
        } else if currentState == .InGame {
            AAPLGameSimulation.sim.gameState = .Paused
        }
    }

    func commonApplicationDidFinishLaunchingWithCompletionHandler(completionHandler: (()->Void)?) {
	// Debugging and Stats
#if DEBUG
        self.scnView.showsStatistics = true
#endif

        self.scnView.backgroundColor = SKColor.blackColor()

        let progress = NSProgress(totalUnitCount: 10)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            progress.becomeCurrentWithPendingUnitCount(2)

            let ui = AAPLInGameScene(size: self.scnView.bounds.size)
            dispatch_async(dispatch_get_main_queue()) {
                self.scnView.overlaySKScene = ui
            }

            progress.resignCurrent()
            progress.becomeCurrentWithPendingUnitCount(3)

            let gameSim = AAPLGameSimulation.sim
            gameSim.gameUIScene = ui

            progress.resignCurrent()
            progress.becomeCurrentWithPendingUnitCount(3)


            SCNTransaction.flush()

		// Preload
            self.scnView.prepareObject(gameSim, shouldAbortBlock: nil)
            progress.resignCurrent()
            progress.becomeCurrentWithPendingUnitCount(1)

		// Game Play Specific Code
            gameSim.gameUIScene!.gameStateDelegate = gameSim.gameLevel
            gameSim.gameLevel.resetLevel()
            gameSim.gameState = .PreGame

            progress.resignCurrent()
            progress.becomeCurrentWithPendingUnitCount(1)

		// GameController hook up
            self.listenForGameControllerWithSim(gameSim)


            dispatch_async(dispatch_get_main_queue()) {
                self.scnView.scene = gameSim
                self.scnView.delegate = gameSim
                completionHandler?()
            }

            progress.resignCurrent()

        }

    }

}