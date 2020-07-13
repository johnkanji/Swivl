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

// MARK: Solve Triangular

  public static func solveTriangular<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol, _ triangle: TriangularType)
  throws -> [T] where T: AccelerateFloatingPoint {
    precondition(shapeA.r == shapeA.c && shapeA.c == shapeB.r)
    var uplo = triangle.rawValue
    var trans = Transpose.noTrans.rawValue
    var diag = Diagonal.nonUnit.rawValue
    var n = __CLPK_integer(shapeA.r)
    var nrhs = __CLPK_integer(shapeB.c)
    var lda = __CLPK_integer(shapeA.r)
    var ldb = __CLPK_integer(shapeA.r)
    var info = __CLPK_integer()
    var A = transpose(a, shapeA)
    var x = transpose(b, shapeB)

    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          dtrtrs_(&uplo, &trans, &diag, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          strtrs_(&uplo, &trans, &diag, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    }
    if info > 0 {
      throw BLASError.singularMatrix
    }
    return transpose(x, (shapeB.c, shapeB.r))
  }


// MARK: Solve Cholesky

  public static func solveCholesky<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol)
  throws -> [T] where T: AccelerateFloatingPoint {
    precondition(shapeA.r == shapeA.c && shapeA.c == shapeB.r)
    var uplo = TriangularType.upper.rawValue
    var n = __CLPK_integer(shapeA.r)
    var nrhs = __CLPK_integer(shapeB.c)
    var lda = __CLPK_integer(shapeA.r)
    var ldb = __CLPK_integer(shapeA.r)
    var info = __CLPK_integer()
    var x = transpose(b, shapeB)
    var A = transpose(a, shapeA)

    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          dposv_(&uplo, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          sposv_(&uplo, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    }
    if info > 0 {
      throw BLASError.singularMatrix
    }
    return transpose(x, (shapeB.c, shapeB.r))
  }


// MARK: Solve LDL

  public static func solveLDL<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol)
  throws -> [T] where T: AccelerateFloatingPoint {
    precondition(shapeA.r == shapeA.c && shapeA.c == shapeB.r)
    var uplo = TriangularType.upper.rawValue
    var n = __CLPK_integer(shapeA.r)
    var nrhs = __CLPK_integer(shapeB.c)
    var lda = __CLPK_integer(shapeA.r)
    var ipiv = [__CLPK_integer](repeating: 0, count: shapeA.r)
    var ldb = __CLPK_integer(shapeA.r)
    var lwork = __CLPK_integer(shapeA.r*shapeA.r)
    var info = __CLPK_integer()
    var x = transpose(b, shapeB)
    var A = transpose(a, shapeA)
    var work = [T](repeating: 0, count: shapeA.r*shapeA.r)

    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          work.withUnsafeMutableBufferPointer(as: Double.self) { pW in
            dsysv_(
              &uplo, &n, &nrhs, pA.baseAddress!, &lda, &ipiv,
              pX.baseAddress!, &ldb, pW.baseAddress!, &lwork, &info)
          }
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          work.withUnsafeMutableBufferPointer(as: Float.self) { pW in
            ssysv_(
              &uplo, &n, &nrhs, pA.baseAddress!, &lda, &ipiv,
              pX.baseAddress!, &ldb, pW.baseAddress!, &lwork, &info)
          }
        }
      }
    }
    if info > 0 {
      throw BLASError.singularMatrix
    }
    return transpose(x, (shapeB.c, shapeB.r))
  }


// MARK: Solve LU

  public static func solveLU<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol)
  throws -> [T] where T: AccelerateFloatingPoint {
    precondition(shapeA.r == shapeA.c && shapeA.c == shapeB.r)
    var n = __CLPK_integer(shapeA.r)
    var nrhs = __CLPK_integer(shapeB.c)
    var lda = __CLPK_integer(shapeA.r)
    var ipiv = [__CLPK_integer](repeating: 0, count: shapeA.r)
    var ldb = __CLPK_integer(shapeA.r)
    var info = __CLPK_integer()
    var x = transpose(b, shapeB)
    var A = transpose(a, shapeA)

    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          dgesv_(&n, &nrhs, pA.baseAddress!, &lda, &ipiv, pX.baseAddress!, &ldb, &info)
        }
      }
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        x.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          sgesv_(&n, &nrhs, pA.baseAddress!, &lda, &ipiv, pX.baseAddress!, &ldb, &info)
        }
      }
    }
    if info > 0 {
      throw BLASError.singularMatrix
    }
    return transpose(x, (shapeB.c, shapeB.r))
  }


//  MARK: Least Squares
  
  public static func leastSquares<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> [T]
  where T: AccelerateFloatingPoint {
    var trans = Transpose.noTrans.rawValue
    var m = __CLPK_integer(shapeA.r)
    var n = __CLPK_integer(shapeA.c)
    var nrhs = __CLPK_integer(shapeB.c)
    var lda = __CLPK_integer(shapeA.r)
    var ldb = __CLPK_integer(shapeA.r)
    var lwork = Swift.min(m,n) + Swift.max(1,m,n,nrhs) * n
    var A = transpose(a, shapeA)
    var B = transpose(b, shapeB)
    var W = [T](repeating: 0, count: Int(lwork))
    var info = __CLPK_integer()
    
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Double.self) { pB in
      W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
        dgels_(&trans, &m, &n, &nrhs, pA.baseAddress!, &lda, pB.baseAddress!, &ldb, pW.baseAddress, &lwork, &info)
      }}}
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Float.self) { pB in
      W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
        sgels_(&trans, &m, &n, &nrhs, pA.baseAddress!, &lda, pB.baseAddress!, &ldb, pW.baseAddress, &lwork, &info)
      }}}
    }
    assert(info == 0, "Matrix must be full rank")

    B = transpose(B, (shapeB.c, shapeB.r))
    if m > n {
      B = block(B, shapeB, startIndex: (0,0), shapeOut: (shapeA.c, shapeB.c))
    }
    return B
    
  }


// MARK:  Constrained Least Squares
  
  public static func leastSquares<T>(
    _ a: [T], _ shapeA: RowCol, _ b: [T], _ c: [T], _ shapeC: RowCol, _ d: [T]
  ) -> [T] where T: AccelerateFloatingPoint {
    var m = __CLPK_integer(shapeA.r)
    var n = __CLPK_integer(shapeA.c)
    var p = __CLPK_integer(shapeC.r)
    var lda = n
    var ldc = __CLPK_integer(shapeC.c)
    var lwork = n+p+Swift.max(m,n)*n
    var A = transpose(a, shapeA)
    var B = b
    var C = transpose(c, shapeC)
    var D = d
    var W = [T](repeating: 0, count: Int(lwork))
    var info = __CLPK_integer()

    var X = [T](repeating: 0, count: shapeA.c)
    if T.self is Double.Type {
      A.withUnsafeMutableBufferPointer(as: Double.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Double.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Double.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Double.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Double.self) { pX in
      W.withUnsafeMutableBufferPointer(as: Double.self) { pW in
        dgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc, pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lwork, &info)
      }}}}}}
    } else {
      A.withUnsafeMutableBufferPointer(as: Float.self) { pA in
      B.withUnsafeMutableBufferPointer(as: Float.self) { pB in
      C.withUnsafeMutableBufferPointer(as: Float.self) { pC in
      D.withUnsafeMutableBufferPointer(as: Float.self) { pD in
      X.withUnsafeMutableBufferPointer(as: Float.self) { pX in
      W.withUnsafeMutableBufferPointer(as: Float.self) { pW in
        sgglse_(&m, &n, &p, pA.baseAddress!, &lda, pC.baseAddress!, &ldc, pB.baseAddress!, pD.baseAddress!, pX.baseAddress!, pW.baseAddress!, &lwork, &info)
      }}}}}}
    }
    return X
  }
  
}
