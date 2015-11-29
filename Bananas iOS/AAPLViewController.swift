//
//  AAPLViewController.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/28.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  A view controller that manages an AAPLSceneView instance for displaying the game.

 */

import UIKit

@objc(AAPLViewController)
class AAPLViewController: UIViewController {
    
    var sceneView: AAPLSceneView {
        return self.view as! AAPLSceneView
    }
    
    override func loadView() {
        self.view = AAPLSceneView()
    }
    
}