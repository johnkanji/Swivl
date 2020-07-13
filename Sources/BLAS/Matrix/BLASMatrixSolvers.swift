//  BLASMatrixSolvers.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import CLapacke

extension BLAS {
  
  public static func linearLeastSquares<T>(_ a: [T], shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> [T]
  where T: AccelerateFloatingPoint {
    let trans = Transpose.noTrans.rawValue
    let m = Int32(shapeA.r)
    let n = Int32(shapeA.c)
    let nrhs = Int32(shapeB.c)
    var A = a
    var B = b
    var info = Int32()
    
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { ptrA in
        B.withUnsafeMutableBufferPointer(as: Double.self) { ptrB in
          info = LAPACKE_dgels(rowMajor, trans, m, n, nrhs, ptrA.baseAddress!, n, ptrB.baseAddress!, nrhs)
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { ptrA in
        B.withUnsafeMutableBufferPointer(as: Float.self) { ptrB in
          info = LAPACKE_sgels(rowMajor, trans, m, n, nrhs, ptrA.baseAddress!, n, ptrB.baseAddress!, nrhs)
        }
      }
    }
    assert(info == 0, "Matrix must be full rank")
    
    if m > n {
      B = block(B, shapeB, startIndex: (0,0), shapeOut: (shapeA.c, shapeB.c))
    }
    return B
    
  }
  
  public static func linearLeastSquares<T>(
    _ a: [T], shapeA: RowCol, _ b: [T], _ c: [T], shapeC: RowCol, _ d: [T]
  ) throws -> [T] where T: AccelerateFloatingPoint {
    let m = Int32(shapeA.r)
    let n = Int32(shapeA.c)
    let p = Int32(shapeC.r)
    var A = a
    var B = b
    var C = c
    var D = d
    let lda = n
    let ldc = Int32(shapeC.c)
    var info = Int32()

    var X = [T](repeating: 0, count: shapeA.c)
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Double.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Double.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Double.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Double.self) { pX in
        info = LAPACKE_dgglse(
          rowMajor, m, n, p, pA.baseAddress!, lda, pC.baseAddress!, ldc,
          pB.baseAddress!, pD.baseAddress!, pX.baseAddress!)
      }}}}}
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Float.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Float.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Float.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Float.self) { pX in
        info = LAPACKE_sgglse(
          rowMajor, m, n, p, pA.baseAddress!, lda, pC.baseAddress!, ldc,
          pB.baseAddress!, pD.baseAddress!, pX.baseAddress!)
      }}}}}
    }
    if info > 0 {
      throw BLASError.linearLeastSquaresFaliure
    }
    return X
  }
  
}
