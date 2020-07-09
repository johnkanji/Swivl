//  BLASVectorGeometry.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension BLAS {
  
  public static func length<T>(_ a: [T]) -> T where T: AccelerateFloatingPoint {
    sqrt(BLAS.dot(a, a))
  }
  
  public static func dist<T>(_ a: [T], _ b: [T]) -> T where T: AccelerateFloatingPoint {
    if T.self is Double.Type {
      return vDSP.distanceSquared(a as! [Double], b as! [Double]) as! T
    } else {
      return vDSP.distanceSquared(a as! [Float], b as! [Float]) as! T
    }
  }
  
}
