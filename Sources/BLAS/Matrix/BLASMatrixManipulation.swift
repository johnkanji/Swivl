//  BLASMatrixManipulation.swift
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
  
  public static func transpose<T>(_ a: [T], _ shapeA: RowCol) -> [T] where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(shapeA.c)
    let n = vDSP_Length(shapeA.r)
    var c = [T](repeating: 0, count: a.count)

    if memoryCompatible(Double.self, T.self) {
      c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
        a.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mtransD(ptrA.baseAddress!, s1, ptrC.baseAddress!, s1, m, n)
        }
      }
      return c
    } else {
      c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
        a.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mtrans(ptrA.baseAddress!, s1, ptrC.baseAddress!, s1, m, n)
        }
      }
      return c
    }
  }

  
  public static func col<T>(_ a: [T], _ shape: RowCol, _ c: Int) -> [T]
  where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(1)
    let n = vDSP_Length(shape.r)
    let ta = vDSP_Length(shape.c)
    var out = [T](repeating: 0, count: shape.r)

    if memoryCompatible(Double.self, T.self) {
      out.withUnsafeMutableBufferPointer(as: Double.self) { ptrOut in
        a.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + c, ptrOut.baseAddress!, m, n, ta, m)
        }
      }
      return out
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { ptrOut in
        a.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + c, ptrOut.baseAddress!, m, n, ta, m)
        }
      }
      return out
    }
  }
  
  public static func row<T>(_ a: [T], _ shape: RowCol, _ r: Int) -> [T]
  where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(shape.c)
    let n = vDSP_Length(1)
    var out = [T](repeating: 0, count: shape.c)

    if memoryCompatible(Double.self, T.self) {
      out.withUnsafeMutableBufferPointer(as: Double.self) { ptrOut in
        a.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + r*shape.c, ptrOut.baseAddress!, m, n, m, m)
        }
      }
      return out
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { ptrOut in
        a.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + r*shape.c, ptrOut.baseAddress!, m, n, m, m)
        }
      }
      return out
    }
  }
  
  public static func block<T>(_ a: [T], _ shapeA: RowCol, startIndex: RowCol, shapeOut: RowCol) -> [T]
  where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(shapeOut.c)
    let n = vDSP_Length(shapeOut.r)
    let ta = vDSP_Length(shapeA.c)
    let i = startIndex.r * shapeA.c + startIndex.c
    var c = [T](repeating: 0, count: shapeOut.r * shapeOut.c)
    if memoryCompatible(Double.self, T.self) {
      c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
        a.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + i, ptrC.baseAddress!, m, n, ta, m)
        }
      }
      return c
    } else {
      c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
        a.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + i, ptrC.baseAddress!, m, n, ta, m)
        }
      }
      return c
    }
  }
  
  public static func setBlock<T>(
    _ a: UnsafeMutablePointer<T>, _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol, startIndex: RowCol)
  where T: AccelerateNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))
    
    let m = vDSP_Length(shapeB.c)
    let n = vDSP_Length(shapeB.r)
    let tc = vDSP_Length(shapeA.c)
    let i = startIndex.r * shapeA.c + startIndex.c
    if memoryCompatible(Double.self, T.self) {
      b.withUnsafeBufferPointer(as: Double.self) { ptrB in
        a.withMemoryRebound(to: Double.self, capacity: shapeA.r*shapeA.c) { pa in
          vDSP_mmovD(ptrB.baseAddress!, pa + i, m, n, m, tc)
        }
      }
    } else {
      b.withUnsafeBufferPointer(as: Float.self) { ptrB in
        a.withMemoryRebound(to: Float.self, capacity: shapeA.r*shapeA.c) { pa in
          vDSP_mmov(ptrB.baseAddress!, pa + i, m, n, m, tc)
        }
      }
    }
  }


  public static func hcat<T>(_ vs: [[T]], shapes: [RowCol]) -> [T]
  where T: AccelerateNumeric {
    precondition(shapes.allSatisfy { s in s.r == shapes[0].r })
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let shapeOut = RowCol(shapes[0].r, shapes.map(\.c).reduce(0, +))
    let n = vDSP_Length(shapeOut.r)
    let tc = vDSP_Length(shapeOut.c)
    var c = [T](repeating: 0, count: shapeOut.r * shapeOut.c)
    var col = 0
    
    if memoryCompatible(Double.self, T.self) {
      zip(vs, shapes).forEach { v, shapeV in
        let m = vDSP_Length(shapeV.c)
        c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
          v.withUnsafeBufferPointer(as: Double.self) { ptrV in
            vDSP_mmovD(ptrV.baseAddress!, ptrC.baseAddress! + col, m, n, m, tc)
          }
        }
        col += shapeV.c
      }
      return c
    } else {
      zip(vs, shapes).forEach { v, shapeV in
        let m = vDSP_Length(shapeV.c)
        c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
          v.withUnsafeBufferPointer(as: Float.self) { ptrV in
            vDSP_mmov(ptrV.baseAddress!, ptrC.baseAddress! + col, m, n, m, tc)
          }
        }
        col += shapeV.c
      }
      return c
    }
  }
  public static func hcat<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> [T]
  where T: AccelerateNumeric {
    return hcat([a, b], shapes: [shapeA, shapeB])
  }
  
  public static func vcat<T>(_ vs: [[T]], shapes: [RowCol]) -> [T]
  where T: AccelerateNumeric {
    precondition(shapes.allSatisfy { s in s.c == shapes[0].c })
    return vs.reduce([], +)
  }
  public static func vcat<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> [T]
  where T: AccelerateNumeric {
    return vcat([a, b], shapes: [shapeA, shapeB])
  }
  
  
  static func triangularMask<T>(_ shape: RowCol, type: TriangularType, diagonal k: Int) -> [T]
  where T: AccelerateNumeric {
    var v1: T = 0
    var v2: T = 1
    var k = k
    if type == .upper {
      swap(&v1, &v2)
      k -= 1
    }
    let zs = Array<Int>(Swift.max(-k,0)..<shape.r)
      .map { r in Array<Int>(r*shape.c...r*shape.c + r + k) }
      .reduce([], +)
    var mask = [T](repeating: v1, count: shape.r*shape.c)
    zs.forEach { i in mask[i] = v2 }
    
    return mask
  }
  
  public enum TriangularType {
    case upper
    case lower
  }

  public static func triangle<T>(
    _ a: [T], _ shape: RowCol,
    type: TriangularType, diagonal: Int = 0, truncate: Bool = false) -> ([T], shape: RowCol)
  where T: AccelerateFloatingPoint {
    
    if !truncate {
      let S: [T] = triangularMask(shape, type: type, diagonal: diagonal)
      return (multiplyElementwise(a, S), shape)
    } else {
      
      let k = type == .lower ? diagonal : -diagonal
      let r = type == .lower ? shape.r : shape.c
      let c = type == .lower ? shape.c : shape.r
      var startIndex = RowCol(Swift.max(0,-k), 0)
      var shapeOut = RowCol(Swift.min(r+k,r), Swift.min(r+k,c))
      if type == .upper {
        startIndex = RowCol(startIndex.c, startIndex.r)
        shapeOut = RowCol(shapeOut.c, shapeOut.r)
      }

      var out: [T] = []
      if shapeOut == shape {
        out = a
      } else {
        out = block(a, shape, startIndex: startIndex, shapeOut: shapeOut)
      }

      let S: [T] = triangularMask(shapeOut, type: type, diagonal: type == .upper ? diagonal : diagonal+1)
      return (multiplyElementwise(out, S), shapeOut)
    }
  }
  
//  //  TODO: leading diagonal
//  public static func upperTriangle<T>(_ a: [T], _ shape: RowCol, includeLeadingDiagonal: Bool = true) -> [T]
//  where T: AccelerateFloatingPoint {
//    precondition(shape.r == shape.c)
//    let S = Array(0..<shape.r).reduce([]) { (flat, i) -> [T] in
//      flat + [T](repeating: 0, count: i) + [T](repeating: 1, count: shape.r-i)
//    }
//    return multiplyElementwise(a, S)
//  }
  
}
