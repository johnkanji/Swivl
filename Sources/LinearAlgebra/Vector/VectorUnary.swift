//  VectorUnary.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension LinAlg {
  
  public static func negate<T>(_ a: [T]) -> [T] where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.negative(a as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.negative(a as! [Float]) as! [T]
    } else {
      return a.map { -$0 }
    }
  }
  

  public static func abs<T>(_ a: [T]) -> [T] where T: SwivlNumeric {
    let n = vDSP_Length(a.count)
    if T.self is Double.Type {
      var c = [Double](repeating: 0, count: a.count)
      vDSP_vabsD(a as! [Double], s1, &c, s1, n)
      return c as! [T]
    } else if T.self is Float.Type {
      var c = [Float](repeating: 0, count: a.count)
      vDSP_vabs(a as! [Float], s1, &c, s1, n)
      return c as! [T]
    } else {
      var c = [Int32](repeating: 0, count: a.count)
      vDSP_vabsi(a as! [Int32], s1, &c, s1, n)
      return c as! [T]
    }
  }
  
  
  public static func max<T>(_ a: [T]) -> (value: T, index: Int) where T: SwivlFloatingPoint {
    let n = vDSP_Length(a.count)
    var ci = vDSP_Length(0)
    if T.self is Double.Type {
      var c: Double = 0
      vDSP_maxviD(a as! [Double], s1, &c, &ci, n)
      return (c as! T, Int(ci))
    } else {
      var c: Float = 0
      vDSP_maxvi(a as! [Float], s1, &c, &ci, n)
      return (c as! T, Int(ci))
    }
  }
  
  public static func min<T>(_ a: [T]) -> (value: T, index: Int) where T: SwivlFloatingPoint {
    let n = vDSP_Length(a.count)
    var ci = vDSP_Length(0)
    if T.self is Double.Type {
      var c: Double = 0
      vDSP_minviD(a as! [Double], s1, &c, &ci, n)
      return (c as! T, Int(ci))
    } else {
      var c: Float = 0
      vDSP_minvi(a as! [Float], s1, &c, &ci, n)
      return (c as! T, Int(ci))
    }
  }
  
  
  public static func sum<T>(_ a: [T]) -> T where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.sum(a as! [Double]) as! T
    } else if T.self is Float.Type {
      return vDSP.sum(a as! [Float]) as! T
    } else {
      return a.sum()
    }
  }
  
  public static func mean<T>(_ a: [T]) -> T where T: SwivlFloatingPoint {
    if T.self is Double.Type {
      return vDSP.mean(a as! [Double]) as! T
    } else {
      return vDSP.mean(a as! [Float]) as! T
    }
  }
  
  
  public static func square<T>(_ a: [T]) -> [T] where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.square(a as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.square(a as! [Float]) as! [T]
    } else {
      return a.map { $0*$0 }
    }
  }
  
}
