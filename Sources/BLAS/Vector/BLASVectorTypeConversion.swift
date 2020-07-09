//  BLASVectorTypeConversion.swift
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
  
  public static func toInteger<T>(_ a: [T], roundingMode: vDSP.RoundingMode = .towardNearestInteger) -> [Int32]
  where T: AccelerateFloatingPoint {
    if T.self is Double.Type {
      return vDSP.floatingPointToInteger(a as! [Double], integerType: Int32.self, rounding: roundingMode)
    } else {
      return vDSP.floatingPointToInteger(a as! [Float], integerType: Int32.self, rounding: roundingMode)
    }
  }
  
  public static func toFloat<T>(_ a: [T]) -> [Float]
  where T: AccelerateNumeric {
    var c = [Float](repeating: 0, count: a.count)
    if T.self is Double.Type {
      vDSP.convertElements(of: a as! [Double], to: &c)
      return c
    } else {
      vDSP.convertElements(of: a as! [Int32], to: &c)
      return c
    }
  }
  
  public static func toDouble<T>(_ a: [T]) -> [Double]
  where T: AccelerateNumeric {
    var c = [Double](repeating: 0, count: a.count)
    if T.self is Float.Type {
      vDSP.convertElements(of: a as! [Float], to: &c)
      return c
    } else {
      vDSP.convertElements(of: a as! [Int32], to: &c)
      return c
    }
  }
  
}
