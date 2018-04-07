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
            return UIApplication.shared.delegate as! AAPLAppDelegate
        #else
            return NSApp.delegate as! AAPLAppDelegate
        #endif
    }

    private func listenForGameControllerWithSim(_ gameSim: AAPLGameSimulation) {
	//-- GameController hook up
        NotificationCenter.default.addObserver(gameSim,
            selector: #selector(gameSim.controllerDidConnect),
            name: .GCControllerDidConnect,
            object: nil)

        NotificationCenter.default.addObserver(gameSim,
            selector: #selector(gameSim.controllerDidDisconnect),
            name: .GCControllerDidDisconnect,
            object: nil)

        GCController.startWirelessControllerDiscovery(completionHandler: nil)
    }

    func togglePaused() {
        let currentState = AAPLGameSimulation.sim.gameState

        if currentState == .paused {
            AAPLGameSimulation.sim.gameState = .inGame
        } else if currentState == .inGame {
            AAPLGameSimulation.sim.gameState = .paused
        }
    }

    func commonApplicationDidFinishLaunchingWithCompletionHandler(_ completionHandler: (()->Void)?) {
	// Debugging and Stats
#if DEBUG
        self.scnView.showsStatistics = true
#endif

        self.scnView.backgroundColor = SKColor.black

        let progress = Progress(totalUnitCount: 10)

        let scnSize = self.scnView.bounds.size
        //### Instantiate `sim` in the main thread
        _ = AAPLGameSimulation.sim
        DispatchQueue.global(qos: .default).async {
            progress.becomeCurrent(withPendingUnitCount: 2)

            let ui = AAPLInGameScene(size: scnSize)
            DispatchQueue.main.async {
                self.scnView.overlaySKScene = ui
            }

            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 3)

            let gameSim = AAPLGameSimulation.sim
            gameSim.gameUIScene = ui

            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 3)


            SCNTransaction.flush()

		// Preload
            self.scnView.prepare(gameSim, shouldAbortBlock: nil)
            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 1)

		// Game Play Specific Code
            gameSim.gameUIScene!.gameStateDelegate = gameSim.gameLevel
            gameSim.gameLevel.resetLevel()
            gameSim.gameState = .preGame

            progress.resignCurrent()
            progress.becomeCurrent(withPendingUnitCount: 1)

		// GameController hook up
            self.listenForGameControllerWithSim(gameSim)


            DispatchQueue.main.async {
                self.scnView.scene = gameSim
                self.scnView.delegate = gameSim
                completionHandler?()
            }

            progress.resignCurrent()

        }

    }

}
