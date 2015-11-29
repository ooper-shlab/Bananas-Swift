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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "fractionCompleted" {
            let fraction = (object as! NSProgress).fractionCompleted
            dispatch_async(dispatch_get_main_queue()) {
                self._progressView?.progress = Float(fraction)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        let rootViewController = AAPLViewController()
        application.statusBarHidden = true
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.purpleColor()
        self.window!.rootViewController = rootViewController
        self.scnView = rootViewController.sceneView
        
        self.window!.makeKeyAndVisible()
        
        
        _progressView = UIProgressView(frame: CGRectInset(self.scnView.bounds, 40, 40))
        self.scnView.addSubview(_progressView!)
        let prepareProgress = NSProgress(totalUnitCount: 1)
        prepareProgress.addObserver(self, forKeyPath: "fractionCompleted", options: .New, context: nil)
        prepareProgress.becomeCurrentWithPendingUnitCount(1)
        
        self.commonApplicationDidFinishLaunchingWithCompletionHandler {
            
            prepareProgress.removeObserver(self, forKeyPath: "fractionCompleted")
            self._progressView!.removeFromSuperview()
            self._progressView = nil
        }
        prepareProgress.resignCurrent()
        
        return true
    }
    
}