//
//  AAPLMathUtils.swift
//  Bananas
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/11/21.
//
//
/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:

  Utility math routines used throughout the app.

 */

import SceneKit

#if os(OSX)
    typealias SCNVectorFloat = CGFloat
#else
    typealias SCNVectorFloat = Float
#endif

func AAPLMatrix4GetPosition(matrix: SCNMatrix4) -> SCNVector3 {
    return SCNVector3(x: matrix.m41, y: matrix.m42, z: matrix.m43)
}

func AAPLMatrix4SetPosition(_matrix: SCNMatrix4, _ v: SCNVector3) -> SCNMatrix4 {
    var matrix = _matrix
    matrix.m41 = v.x; matrix.m42 = v.y; matrix.m43 = v.z
    return matrix
}

func AAPLRandomPercent<T: FloatComputable>() -> T {
    return (T(rand() % 100)) * 0.01
}
