//  LeastSquares.swift
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

  //  MARK: Least Squares

  public static func leastSquares<T>(_ a: Mat<T>, _ b: Mat<T>) -> Mat<T>
  where T: SwivlFloatingPoint {
    var trans = Transpose.noTrans.rawValue
    var m = __CLPK_integer(a.shape.r)
    var n = __CLPK_integer(a.shape.c)
    var nrhs = __CLPK_integer(b.shape.c)
    var lda = __CLPK_integer(a.shape.r)
    var ldb = __CLPK_integer(a.shape.r)
    var lwork = Swift.min(m,n) + Swift.max(1,m,n,nrhs) * n
    var A = transpose(a)
    var B = transpose(b)
    var W = [T](repeating: 0, count: Int(lwork))
    var info = __CLPK_integer()

    if T.self is Double.Type {
      A.flat.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        B.flat.withUnsafeMutableBufferPointer(as: Double.self) { pB in
          W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
            dgels_(&trans, &m, &n, &nrhs, pA.baseAddress!, &lda, pB.baseAddress!, &ldb, pW.baseAddress, &lwork, &info)
          }}}
    } else {
      A.flat.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        B.flat.withUnsafeMutableBufferPointer(as: Float.self) { pB in
          W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
            sgels_(&trans, &m, &n, &nrhs, pA.baseAddress!, &lda, pB.baseAddress!, &ldb, pW.baseAddress, &lwork, &info)
          }}}
    }
    assert(info == 0, "Matrix must be full rank")

    B = transpose(B)
    if m > n {
      B = block(B, startIndex: (0,0), shapeOut: (a.shape.c, b.shape.c))
    }
    return B

  }


  // MARK:  Constrained Least Squares

  public static func leastSquares<T>(_ a: Mat<T>, _ b: [T], _ c: Mat<T>, _ d: [T]) -> [T]
  where T: SwivlFloatingPoint {
    var m = __CLPK_integer(a.shape.r)
    var n = __CLPK_integer(a.shape.c)
    var p = __CLPK_integer(c.shape.r)
    var lda = n
    var ldc = __CLPK_integer(c.shape.c)
    var lwork = n+p+Swift.max(m,n)*n
    var A = transpose(a)
    var B = b
    var C = transpose(c)
    var D = d
    var W = [T](repeating: 0, count: Int(lwork))
    var info = __CLPK_integer()

    var X = [T](repeating: 0, count: a.shape.c)
    if T.self is Double.Type {
      A.flat.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        B.withUnsafeMutableBufferPointer(as: Double.self) { pB in
          C.flat.withUnsafeMutableBufferPointer(as: Double.self) { pC in
            D.withUnsafeMutableBufferPointer(as: Double.self) { pD in
              X.withUnsafeMutableBufferPointer(as: Double.self) { pX in
                W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
                  dgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc, pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lwork, &info)
                }}}}}}
    } else {
      A.flat.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        B.withUnsafeMutableBufferPointer(as: Float.self) { pB in
          C.flat.withUnsafeMutableBufferPointer(as: Float.self) { pC in
            D.withUnsafeMutableBufferPointer(as: Float.self) { pD in
              X.withUnsafeMutableBufferPointer(as: Float.self) { pX in
                W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
                  sgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc, pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lwork, &info)
                }}}}}}
    }
    return X
  }

}
