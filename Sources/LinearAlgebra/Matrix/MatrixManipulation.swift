//  MatrixManipulation.swift
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
  
  public static func transpose<T>(_ a: Mat<T>) -> Mat<T> where T: SwivlNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(a.shape.r)
    let n = vDSP_Length(a.shape.c)
    var c = [T](repeating: 0, count: a.flat.count)

    if memoryCompatible(Double.self, T.self) {
      c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
        a.flat.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mtransD(ptrA.baseAddress!, s1, ptrC.baseAddress!, s1, m, n)
        }
      }
    } else {
      c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
        a.flat.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mtrans(ptrA.baseAddress!, s1, ptrC.baseAddress!, s1, m, n)
        }
      }
    }
    return (c, (a.shape.c, a.shape.r))
  }

  
  public static func col<T>(_ a: Mat<T>, _ c: Int) -> [T]
  where T: SwivlNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(1)
    let n = vDSP_Length(a.shape.r)
    let ta = vDSP_Length(a.shape.c)
    var out = [T](repeating: 0, count: a.shape.r)

    if memoryCompatible(Double.self, T.self) {
      out.withUnsafeMutableBufferPointer(as: Double.self) { ptrOut in
        a.flat.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + c, ptrOut.baseAddress!, m, n, ta, m)
        }
      }
      return out
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { ptrOut in
        a.flat.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + c, ptrOut.baseAddress!, m, n, ta, m)
        }
      }
      return out
    }
  }
  
  public static func row<T>(_ a: Mat<T>, _ r: Int) -> [T]
  where T: SwivlNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(a.shape.c)
    let n = vDSP_Length(1)
    var out = [T](repeating: 0, count: a.shape.c)

    if memoryCompatible(Double.self, T.self) {
      out.withUnsafeMutableBufferPointer(as: Double.self) { ptrOut in
        a.flat.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + r*a.shape.c, ptrOut.baseAddress!, m, n, m, m)
        }
      }
      return out
    } else {
      out.withUnsafeMutableBufferPointer(as: Float.self) { ptrOut in
        a.flat.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + r*a.shape.c, ptrOut.baseAddress!, m, n, m, m)
        }
      }
      return out
    }
  }
  
  public static func block<T>(_ a: Mat<T>, startIndex: RowCol, shapeOut: RowCol) -> Mat<T>
  where T: SwivlNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let m = vDSP_Length(shapeOut.c)
    let n = vDSP_Length(shapeOut.r)
    let ta = vDSP_Length(a.shape.c)
    let i = startIndex.r * a.shape.c + startIndex.c
    var c = [T](repeating: 0, count: shapeOut.r * shapeOut.c)
    if memoryCompatible(Double.self, T.self) {
      c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
        a.flat.withUnsafeBufferPointer(as: Double.self) { ptrA in
          vDSP_mmovD(ptrA.baseAddress! + i, ptrC.baseAddress!, m, n, ta, m)
        }
      }
      return (c, shapeOut)
    } else {
      c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
        a.flat.withUnsafeBufferPointer(as: Float.self) { ptrA in
          vDSP_mmov(ptrA.baseAddress! + i, ptrC.baseAddress!, m, n, ta, m)
        }
      }
      return (c, shapeOut)
    }
  }
  
  public static func setBlock<T>(
    _ a: UnsafeMutablePointer<T>, _ shapeA: RowCol, _ b: Mat<T>, startIndex: RowCol)
  where T: SwivlNumeric {
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))
    
    let m = vDSP_Length(b.shape.c)
    let n = vDSP_Length(b.shape.r)
    let tc = vDSP_Length(shapeA.c)
    let i = startIndex.r * shapeA.c + startIndex.c
    if memoryCompatible(Double.self, T.self) {
      b.flat.withUnsafeBufferPointer(as: Double.self) { ptrB in
        a.withMemoryRebound(to: Double.self, capacity: shapeA.r*shapeA.c) { pa in
          vDSP_mmovD(ptrB.baseAddress!, pa + i, m, n, m, tc)
        }
      }
    } else {
      b.flat.withUnsafeBufferPointer(as: Float.self) { ptrB in
        a.withMemoryRebound(to: Float.self, capacity: shapeA.r*shapeA.c) { pa in
          vDSP_mmov(ptrB.baseAddress!, pa + i, m, n, m, tc)
        }
      }
    }
  }


  public static func hcat<T>(_ ms: [Mat<T>]) -> Mat<T>
  where T: SwivlNumeric {
    precondition(ms.allSatisfy { m in m.shape.r == ms[0].shape.r })
    precondition(memoryCompatible(Double.self, T.self) || memoryCompatible(Float.self, T.self))

    let shapeOut = RowCol(ms[0].shape.r, ms.map({ $0.shape.c }).sum())
    let n = vDSP_Length(shapeOut.r)
    let tc = vDSP_Length(shapeOut.c)
    var c = [T](repeating: 0, count: shapeOut.r * shapeOut.c)
    var col = 0
    
    if memoryCompatible(Double.self, T.self) {
      ms.forEach { mat in
        let m = vDSP_Length(mat.shape.c)
        c.withUnsafeMutableBufferPointer(as: Double.self) { ptrC in
          mat.flat.withUnsafeBufferPointer(as: Double.self) { ptrV in
            vDSP_mmovD(ptrV.baseAddress!, ptrC.baseAddress! + col, m, n, m, tc)
          }
        }
        col += mat.shape.c
      }
      return (c, shapeOut)
    } else {
      ms.forEach { mat in
        let m = vDSP_Length(mat.shape.c)
        c.withUnsafeMutableBufferPointer(as: Float.self) { ptrC in
          mat.flat.withUnsafeBufferPointer(as: Float.self) { ptrV in
            vDSP_mmov(ptrV.baseAddress!, ptrC.baseAddress! + col, m, n, m, tc)
          }
        }
        col += mat.shape.c
      }
      return (c, shapeOut)
    }
  }
  public static func hcat<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T> where T: SwivlNumeric {
    hcat([a, b])
  }
  
  public static func vcat<T>(_ ms: [Mat<T>]) -> Mat<T>
  where T: SwivlNumeric {
    precondition(ms.allSatisfy { m in m.shape.c == ms[0].shape.c })
    return (ms.map(\.flat).chained(), (ms.map({ $0.shape.r }).sum(), ms[0].shape.c))
  }
  public static func vcat<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T>
  where T: SwivlNumeric {
    vcat([a, b])
  }
  
  
  static func triangularMask(_ shape: RowCol, tri: TriangularType, diagonal k: Int) -> [Int] {
    var k = k
    if tri == .upper { k -= 1 }
    let zs = Array<Int>(Swift.max(-k,0)..<shape.r)
      .map { r in Array<Int>(r*shape.c...r*shape.c + r + k) }
      .chained()
    return zs
  }
  
  public static func zeroed<T>(_ a: inout Mat<T>, _ iis: [Int]) where T: SwivlNumeric {
    iis.forEach { i in a.flat[i] = 0 }
  }

  public static func triangle<T>(_ a: Mat<T>, _ tri: TriangularType, diagonal: Int = 0, truncate: Bool = false)
  -> Mat<T>
  where T: SwivlNumeric {
    
    if !truncate {
      var out = a
      zeroed(&out, triangularMask(a.shape, tri: tri, diagonal: diagonal))
      return out
    } else {
      
      let k = tri == .lower ? diagonal : -diagonal
      let r = tri == .lower ? a.shape.r : a.shape.c
      let c = tri == .lower ? a.shape.c : a.shape.r
      var startIndex = RowCol(Swift.max(0,-k), 0)
      var shapeOut = RowCol(Swift.min(r+k,r), Swift.min(r+k,c))
      if tri == .upper {
        startIndex = RowCol(startIndex.c, startIndex.r)
        shapeOut = RowCol(shapeOut.c, shapeOut.r)
      }

      var out = Mat<T>([],(0,0))
      if shapeOut == a.shape {
        out = a
      } else {
        out = block(a, startIndex: startIndex, shapeOut: shapeOut)
      }

      let S = triangularMask(shapeOut, tri: tri, diagonal: tri == .upper ? diagonal : diagonal+1)
      zeroed(&out, S)
      return out
    }
  }
  
}
