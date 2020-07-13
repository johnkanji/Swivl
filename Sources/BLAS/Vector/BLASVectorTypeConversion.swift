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
  
  public static func toInteger<T>(_ a: [T], roundingMode: RoundingMode = .towardNearestInteger) -> [Int32]
  where T: AccelerateNumeric {
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

  public static func toType<T, U>(_ a: [T], _ type: U.Type) -> [U]
  where T: AccelerateNumeric, U: AccelerateNumeric {
    if U.self is Double.Type {
      return toDouble(a) as! [U]
    } else if U.self is Double.Type {
      return toFloat(a) as! [U]
    } else {
      return toInteger(a) as! [U]
    }
  }
  
}
