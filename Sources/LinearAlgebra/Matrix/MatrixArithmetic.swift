//  MatrixArithmetic.swift
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
  
  public static func multiplyMatrix<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T> where T: SwivlFloatingPoint {
    precondition(a.shape.c == b.shape.r)
    let m = vDSP_Length(a.shape.r)
    let n = vDSP_Length(b.shape.c)
    let p = vDSP_Length(a.shape.c)
    var c = [T](repeating: 0, count: Int(m*n))
    if T.self is Double.Type {
      a.flat.withUnsafeBufferPointer(as: Double.self) { pA in
      b.flat.withUnsafeBufferPointer(as: Double.self) { pB in
      c.withUnsafeMutableBufferPointer(as: Double.self) { pC in
        vDSP_mmulD(pA.baseAddress!, s1, pB.baseAddress!, s1, pC.baseAddress!, s1, m, n, p)
      }}}
    } else {
      a.flat.withUnsafeBufferPointer(as: Float.self) { pA in
      b.flat.withUnsafeBufferPointer(as: Float.self) { pB in
      c.withUnsafeMutableBufferPointer(as: Float.self) { pC in
        vDSP_mmul(pA.baseAddress!, s1, pB.baseAddress!, s1, pC.baseAddress!, s1, m, n, p)
      }}}
    }
    return (c, (Int(m), Int(n)))
  }

  public static func multiplyMatrix<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T> where T: SwivlNumeric {
    precondition(a.shape.c == b.shape.r)
    let (m, p) = a.shape
    let n = b.shape.c
    let shapeOut = RowCol(m,n)
    var out = [T](repeating: 0, count: m*n)
    var acc: T = 0
    for r in 0..<m {
      for c in 0..<n {
        acc = 0
        for i in 0..<p {
          acc += a.flat[r*a.shape.c + i]*b.flat[i*b.shape.c + c]
        }
        out[r*shapeOut.c + c] = acc
      }
    }
    return (out, shapeOut)
  }

  public static func multiplyMatrixVector<T>(_ a: Mat<T>, _ b: [T]) -> [T]
  where T: SwivlFloatingPoint {
    precondition(a.shape.c == b.count)

    let m = Int32(a.shape.r)
    let n = Int32(a.shape.c)
    var y = [T](repeating: 0, count: a.shape.r)

    if T.self is Double.Type {
      a.flat.withUnsafeBufferPointer(as: Double.self) { pA in
      b.withUnsafeBufferPointer(as: Double.self) { pB in
      y.withUnsafeMutableBufferPointer(as: Double.self) { pY in
        cblas_dgemv(CblasRowMajor, CblasNoTrans, m, n, 1, pA.baseAddress!, n, pB.baseAddress!, 1, 0, pY.baseAddress!, 1)
      }}}
    } else {
      a.flat.withUnsafeBufferPointer(as: Float.self) { pA in
      b.withUnsafeBufferPointer(as: Float.self) { pB in
      y.withUnsafeMutableBufferPointer(as: Float.self) { pY in
        cblas_sgemv(CblasRowMajor, CblasNoTrans, m, n, 1, pA.baseAddress!, n, pB.baseAddress!, 1, 0, pY.baseAddress!, 1)
      }}}
    }
    return y
  }

}
