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
import CLapacke

extension BLAS {

  public static func linear<T>(_ start: T, _ stop: T, _ count: Int) -> [T] where T: AccelerateFloatingPoint {
    if T.self is Double.Type {
      return vDSP.ramp(in: Double(start)...Double(stop), count: count) as! [T]
    } else {
      return vDSP.ramp(in: Float(start)...Float(stop), count: count) as! [T]
    }
  }
  
  static func _rand<T>(_ count: Int, distribution: Distribution) -> [T] where T: AccelerateFloatingPoint {
    let idist = distribution.rawValue
    var iseed = (0..<4).map { _ in Int32.random(in: 0...4095) }
    let n = Int32(count)
    var x = [T](repeating: 0.0, count: count)
    
    if T.self is Double.Type {
      x.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
        LAPACKE_dlarnv(idist, &iseed, n, ptr.baseAddress!)
      }
    } else {
      x.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
        LAPACKE_slarnv(idist, &iseed, n, ptr.baseAddress!)
      }
    }
    return x
  }
  public static func rand<T>(_ count: Int) -> [T] where T: AccelerateFloatingPoint {
    return _rand(count, distribution: .uniform)
  }
  public static func randn<T>(_ count: Int) -> [T] where T: AccelerateFloatingPoint {
    return _rand(count, distribution: .normal)
  }
  
}
