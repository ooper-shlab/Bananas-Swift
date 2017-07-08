//
//  AAPLAppDelegateOSX.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/28.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  The OS X-specific implementation of the application delegate. See AAPLAppDelegate for implementation shared between platforms.

 */

import Cocoa

@NSApplicationMain
@objc(AAPLAppDelegateOSX)
class AAPLAppDelegateOSX: AAPLAppDelegate, NSApplicationDelegate {

    @IBOutlet var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        self.window?.disableSnapshotRestoration()

        self.commonApplicationDidFinishLaunchingWithCompletionHandler(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func pause(_: AnyObject) {
        self.togglePaused()
    }

}
