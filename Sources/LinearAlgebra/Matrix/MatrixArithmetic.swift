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
  
  public static func multiplyMatrix<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T>
  where T: SwivlFloatingPoint {
    precondition(a.shape.c == b.shape.r)
    let m = vDSP_Length(a.shape.r)
    let n = vDSP_Length(b.shape.c)
    let p = vDSP_Length(a.shape.c)
    if T.self is Double.Type {
      var c = [Double](repeating: 0, count: Int(m*n))
      vDSP_mmulD(a.flat as! [Double], s1, b.flat as! [Double], s1, &c, s1, m, n, p)
      return (c as! [T], (Int(m), Int(n)))
    } else {
      var c = [Float](repeating: 0, count: Int(m*n))
      vDSP_mmul(a.flat as! [Float], s1, b.flat as! [Float], s1, &c, s1, m, n, p)
      return (c as! [T], (Int(m), Int(n)))
    }
  }

  public static func multiplyMatrixVector<T>(_ a: Mat<T>, _ b: [T]) -> [T]
  where T: SwivlFloatingPoint {
    precondition(a.shape.c == b.count)

    let m = Int32(a.shape.r)
    let n = Int32(a.shape.c)
    var y = [T](repeating: 0, count: b.count)

    if T.self is Double.Type {
      y.withUnsafeMutableBufferPointer(as: Double.self) { pY in
        cblas_dgemv(CblasRowMajor, CblasNoTrans, m, n, 1, a.flat as! [Double], n, b as! [Double], 1, 0, pY.baseAddress!, 1)
      }
    } else {
      y.withUnsafeMutableBufferPointer(as: Float.self) { pY in
        cblas_sgemv(CblasRowMajor, CblasNoTrans, m, n, 1, a.flat as! [Float], n, b as! [Float], 1, 0, pY.baseAddress!, 1)
      }
    }
    return y
  }

}
