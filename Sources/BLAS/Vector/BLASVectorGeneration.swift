//  BLASVectorGeneration.swift
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
  
  enum Distribution: __CLPK_integer {
    case uniform = 1
    case normal = 3
  }

  public static func linear<T>(_ start: T, _ stop: T, _ count: Int) -> [T] where T: AccelerateFloatingPoint {
    if T.self is Double.Type {
      return vDSP.ramp(in: Double(start)...Double(stop), count: count) as! [T]
    } else {
      return vDSP.ramp(in: Float(start)...Float(stop), count: count) as! [T]
    }
  }
  
  static func _rand<T>(_ count: Int, distribution: Distribution) -> [T] where T: AccelerateFloatingPoint {
    var iDist = distribution.rawValue
    var iSeed = (0..<4).map { _ in __CLPK_integer.random(in: 0...4095) }
    var n = __CLPK_integer(count)
    if T.self is Double.Type {
      var x = [Double](repeating: 0.0, count: count)
      dlarnv_(&iDist, &iSeed, &n, &x)
      return x as! [T]
    } else {
      var x = [Float](repeating: 0.0, count: count)
      slarnv_(&iDist, &iSeed, &n, &x)
      return x as! [T]
    }
  }
  public static func rand<T>(_ count: Int) -> [T] where T: AccelerateFloatingPoint {
    return _rand(count, distribution: .uniform)
  }
  public static func randn<T>(_ count: Int) -> [T] where T: AccelerateFloatingPoint {
    return _rand(count, distribution: .normal)
  }
  
}
