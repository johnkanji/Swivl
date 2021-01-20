//  VectorArithmetic.swift
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

  //  MARK: - Vector-Vector arithmetic operations
  
  public static func add<T>(_ a: [T], _ b: [T]) -> [T] where T: SwivlNumeric {
    if a.count == 1 {
      return addScalar(b, a.first!)
    } else if b.count == 1 {
      return addScalar(a, b.first!)
    }
    precondition(a.count == b.count)
    let n = vDSP_Length(a.count)
    if T.self is Double.Type {
      var c = [Double](repeating: 0, count: a.count)
      vDSP_vaddD(a as! [Double], s1, b as! [Double], s1, &c, s1, n)
      return c as! [T]
    } else if T.self is Float.Type {
      var c = [Float](repeating: 0, count: a.count)
      vDSP_vadd(a as! [Float], s1, b as! [Float], s1, &c, s1, n)
      return c as! [T]
    } else {
      var c = [Int32](repeating: 0, count: a.count)
      vDSP_vaddi(a as! [Int32], s1, b as! [Int32], s1, &c, s1, n)
      return c as! [T]
    }
  }
  
  public static func subtract<T>(_ a: [T], _ b: [T]) -> [T] where T: SwivlNumeric {
    precondition(a.count == b.count)
    if T.self is Double.Type {
      return vDSP.subtract(a as! [Double], b as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.subtract(a as! [Float], b as! [Float]) as! [T]
    } else {
      return LinAlg.add(a, b.map { -$0 })
    }
  }
  
  public static func multiplyElementwise<T>(_ a: [T], _ b: [T]) -> [T] where T: SwivlNumeric {
    precondition(a.count == b.count)
    if T.self is Double.Type {
      return vDSP.multiply(a as! [Double], b as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.multiply(a as! [Float], b as! [Float]) as! [T]
    } else {
      return zip(a, b).map { l, r in l * r }
    }
  }
  
  public static func divideElementwise<T>(_ a: [T], _ b: [T]) -> [T] where T: SwivlNumeric {
    precondition(a.count == b.count)
    if T.self is Double.Type {
      return vDSP.divide(a as! [Double], b as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.divide(a as! [Float], b as! [Float]) as! [T]
    } else {
      let n = vDSP_Length(a.count)
      var c = [Int32](repeating: 0, count: a.count)
      vDSP_vdivi(b as! [Int32], s1, a as! [Int32], s1, &c, s1, n)
      return c as! [T]
    }
  }
  
  public static func dot<T>(_ a: [T], _ b: [T]) -> T where T: SwivlNumeric {
    precondition(a.count == b.count)
    if T.self is Double.Type {
      return vDSP.dot(a as! [Double], b as! [Double]) as! T
    } else if T.self is Float.Type {
      return vDSP.dot(a as! [Float], b as! [Float]) as! T
    } else {
      return zip(a, b).reduce(0) { (acc, val) -> T in acc+(val.0*val.1) }
    }
  }
  
  //  MARK: - Vector-Scalar arithmetic operations
  
  public static func addScalar<T>(_ a: [T], _ b: T) -> [T] where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.add(b as! Double, a as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.add(b as! Float, a as! [Float]) as! [T]
    } else {
      let n = vDSP_Length(a.count)
      var b = b as! Int32
      var c = [Int32](repeating: 0, count: a.count)
      vDSP_vsaddi(a as! [Int32], s1, &b, &c, s1, n)
      return c as! [T]
    }
  }
  
  public static func subtractScalar<T>(_ a: [T], _ b: T) -> [T] where T: SwivlNumeric {
    return addScalar(a, -b)
  }
  
  public static func multiplyScalar<T>(_ a: [T], _ b: T) -> [T] where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.multiply(b as! Double, a as! [Double]) as! [T]
    } else if T.self is Float.Type {
      return vDSP.multiply(b as! Float, a as! [Float]) as! [T]
    } else {
      return a.map { l in l * b }
    }
  }

  public static func divideScalar<T>(_ a: [T], _ b: T) -> [T] where T: SwivlNumeric {
    if T.self is Double.Type {
      return vDSP.divide(a as! [Double], b as! Double) as! [T]
    } else if T.self is Float.Type {
      return vDSP.divide(a as! [Float], b as! Float) as! [T]
    } else {
      let n = vDSP_Length(a.count)
      var b = b as! Int32
      var c = [Int32](repeating: 0, count: a.count)
      vDSP_vsdivi(a as! [Int32], s1, &b, &c, s1, n)
      return c as! [T]
    }
  }

}
