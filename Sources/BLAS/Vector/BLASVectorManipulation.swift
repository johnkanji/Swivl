//  BLASVectorManipulation.swift
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
  
  public static func gather<T>(_ a: [T], _ indices: [Int]) -> [T] where T:AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))
    
    var c = [T](repeating: 0, count: indices.count)
    let n = vDSP_Length(indices.count)
    
    if memoryCompatible(Double.self, T.self) {
      let iis = indices.map(Double.init)
      c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
        a.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_vindexD(ptrA.baseAddress!, iis, s1, ptrC.baseAddress!, s1, n)
        }
      }
      return c
    } else {
      let iis = indices.map(Float.init)
      c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
        a.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_vindex(ptrA.baseAddress!, iis, s1, ptrC.baseAddress!, s1, n)
        }
      }
      return c
    }
  }
  
  
  public static func reverseInPlace<T>(_ a: UnsafeMutablePointer<T>, count: Int) where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))
    let n = vDSP_Length(count)
    if memoryCompatible(Double.self, T.self) {
      a.withMemoryRebound(to: Double.self, capacity: count) { p in
        vDSP_vrvrsD(p, s1, n)
      }
    } else {
      a.withMemoryRebound(to: Float.self, capacity: count) { p in
        vDSP_vrvrs(p, s1, n)
      }
    }
  }
  
  public static func reverse<T>(_ a: [T]) -> [T] where T: AccelerateNumeric {
    var c = a
    reverseInPlace(&c, count: c.count)
    return c
  }
  
  
  public static func sort<T>(_ a: [T], order: vDSP.SortOrder) -> [T]
  where T: AccelerateFloatingPoint {
    var c = a
    sortInPlace(&c, count: a.count, order: order)
    return c
  }
  
  public static func sortInPlace<T>(_ a: UnsafeMutablePointer<T>, count: Int, order: vDSP.SortOrder)
  where T: AccelerateFloatingPoint {
    let n = vDSP_Length(count)
    let sortOrder: Int32 = order == .ascending ? 1 : -1
    if T.self is Double.Type {
      vDSP_vsortD(a as! UnsafeMutablePointer<Double>, n, sortOrder)
    } else {
      vDSP_vsortD(a as! UnsafeMutablePointer<Double>, n, sortOrder)
    }
  }
  
  public static func sortedIndices<T>(_ a: [T], order: vDSP.SortOrder) -> [Int]
  where T: AccelerateFloatingPoint {
    let n = vDSP_Length(a.count)
    var iis = (0..<a.count).map(vDSP_Length.init)
    let sortOrder: Int32 = order == .ascending ? 1 : -1
    if T.self is Double.Type {
      vDSP_vsortiD(a as! [Double], &iis, nil, n, sortOrder)
      return iis.map(numericCast)
    } else {
      vDSP_vsorti(a as! [Float], &iis, nil, n, sortOrder)
      return iis.map(numericCast)
    }
  }
  
}
