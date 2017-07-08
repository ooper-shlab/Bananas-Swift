//
//  AAPLAppDelegateIOS.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/28.
//
//
/*
Copyright (C) 2014 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:

The iOS-specific implementation of the application delegate. See AAPLAppDelegate for implementation shared between platforms. Uses NSProgress to display a loading UI while the app loads its assets.

*/

import UIKit

@UIApplicationMain
@objc(AAPLAppDelegateIOS)
class AAPLAppDelegateIOS: AAPLAppDelegate, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private var _progressView: UIProgressView?
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "fractionCompleted" {
            let fraction = (object as! Progress).fractionCompleted
            DispatchQueue.main.async {
                self._progressView?.progress = Float(fraction)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change , context: context)
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        let rootViewController = AAPLViewController()
        application.isStatusBarHidden = true
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.purple
        self.window!.rootViewController = rootViewController
        self.scnView = rootViewController.sceneView
        
        self.window!.makeKeyAndVisible()
        
        
        _progressView = UIProgressView(frame: self.scnView.bounds.insetBy(dx: 40, dy: 40))
        self.scnView.addSubview(_progressView!)
        let prepareProgress = Progress(totalUnitCount: 1)
        prepareProgress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: nil)
        prepareProgress.becomeCurrent(withPendingUnitCount: 1)
        
        self.commonApplicationDidFinishLaunchingWithCompletionHandler {
            
            prepareProgress.removeObserver(self, forKeyPath: "fractionCompleted")
            self._progressView!.removeFromSuperview()
            self._progressView = nil
        }
        prepareProgress.resignCurrent()
        
        return true
    }
    
}
