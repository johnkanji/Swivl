//  BLASMatrixSolvers.swift
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
  
  //  TODO: STUB
  public static func linearLeastSquares<T>(_ a: [T], shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> [T]
  where T: AccelerateFloatingPoint {
    var trans = Int8(Character("N").asciiValue!)
    var m = __CLPK_integer(shapeA.r)
    var n = __CLPK_integer(shapeA.c)
    var nrhs = __CLPK_integer(shapeB.c)
    var A = BLAS.transpose(a, shapeA)
    var lda = __CLPK_integer(shapeA.c)
    var B = BLAS.transpose(b, shapeB)
    var ldb = __CLPK_integer(shapeB.c)
    var work = [T](repeating: 0, count: 4*shapeA.r*shapeA.c)
    var lwork = __CLPK_integer(4*shapeA.r*shapeA.c)
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { ptrA in
        B.withUnsafeMutableBufferPointer(as: Double.self) { ptrB in
          work.withUnsafeMutableBufferPointer(as: Double.self) { ptrW in
            dgels_(&trans, &m, &n, &nrhs, ptrA.baseAddress!, &lda, ptrB.baseAddress!, &ldb, ptrW.baseAddress!, &lwork, &info)
          }
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { ptrA in
        B.withUnsafeMutableBufferPointer(as: Float.self) { ptrB in
          work.withUnsafeMutableBufferPointer(as: Float.self) { ptrW in
            sgels_(&trans, &m, &n, &nrhs, ptrA.baseAddress!, &lda, ptrB.baseAddress!, &ldb, ptrW.baseAddress!, &lwork, &info)
          }
        }
      }
    }
    assert(info == 0, "Matrix must be full rank")
    
    B = transpose(B, (shapeB.c, shapeB.r))
    if m > n {
      B = block(B, shapeB, startIndex: (0,0), shapeOut: (shapeA.c, shapeB.c))
    }
    return B
    
  }
  
  public static func linearLeastSquares<T>(
    _ a: [T], shapeA: RowCol, _ b: [T], _ c: [T], shapeC: RowCol, _ d: [T]
  ) -> [T] where T: AccelerateFloatingPoint {
    var m = __CLPK_integer(shapeA.r)
    var n = __CLPK_integer(shapeA.c)
    var p = __CLPK_integer(shapeC.r)
    var A = BLAS.transpose(a, shapeA)
    var lda = __CLPK_integer(shapeA.r)
    var B = b
    var C = BLAS.transpose(c, shapeC)
    var ldc = __CLPK_integer(shapeC.r)
    var D = d
    var W = [T](repeating: 0, count: 4*shapeA.r*shapeA.c)
    var lw = __CLPK_integer(4*shapeA.r*shapeA.c)
    var info = __CLPK_integer()
    var X = [T](repeating: 0, count: shapeA.c)
    
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Double.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Double.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Double.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Double.self) { pX in
      W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
        dgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc,
                pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lw, &info)
      }}}}}}
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Float.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Float.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Float.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Float.self) { pX in
      W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
        sgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc,
                pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lw, &info)
      }}}}}}
    }
    return X
  }
  
}
