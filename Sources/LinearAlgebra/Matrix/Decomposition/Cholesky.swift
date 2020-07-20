//  Cholesky.swift
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

  public static func chol<T>(_ a: Mat<T>, triangle: TriangularType = .upper) throws -> Mat<T>
  where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c, "Matrix must be symmetric")
    var uplo = triangle.rawValue
    var n = __CLPK_integer(a.shape.r)
    var out = transpose(a)
    var lda = __CLPK_integer(a.shape.r)
    var info = __CLPK_integer()

    if T.self is Double.Type {
      out.flat.withUnsafeMutableBufferPointer(as: Double.self) { ptr in
        dpotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    } else {
      out.flat.withUnsafeMutableBufferPointer(as: Float.self) { ptr in
        spotrf_(&uplo, &n, ptr.baseAddress!, &lda, &info)
      }
    }
    if info > 0 { throw LinAlgError.invalidMatrix("Matrix must be positive-definite") }
    return LinAlg.triangle(transpose(out), triangle)
  }

}


