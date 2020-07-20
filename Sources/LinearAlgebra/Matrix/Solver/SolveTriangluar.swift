//  SolveTriangular.swift
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

  public static func solveTriangular<T>(_ a: Mat<T>, _ b: Mat<T>, _ triangle: TriangularType)
  throws -> Mat<T> where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c && a.shape.c == b.shape.r)
    var uplo = triangle.rawValue
    var trans = Transpose.noTrans.rawValue
    var diag = Diagonal.nonUnit.rawValue
    var n = __CLPK_integer(a.shape.r)
    var nrhs = __CLPK_integer(b.shape.c)
    var lda = __CLPK_integer(a.shape.r)
    var ldb = __CLPK_integer(a.shape.r)
    var info = __CLPK_integer()
    var A = transpose(a)
    var x = transpose(b)

    if T.self is Double.Type {
      A.flat.withUnsafeMutableBufferPointer(as: Double.self) { pA in
        x.flat.withUnsafeMutableBufferPointer(as: Double.self) { pX in
          dtrtrs_(&uplo, &trans, &diag, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    } else {
      A.flat.withUnsafeMutableBufferPointer(as: Float.self) { pA in
        x.flat.withUnsafeMutableBufferPointer(as: Float.self) { pX in
          strtrs_(&uplo, &trans, &diag, &n, &nrhs, pA.baseAddress!, &lda, pX.baseAddress!, &ldb, &info)
        }
      }
    }
    if info > 0 {
      throw LinAlgError.singularMatrix
    }
    return transpose(x)
  }

}
