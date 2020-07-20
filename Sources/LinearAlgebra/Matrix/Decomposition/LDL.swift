//  LDL.swift
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

  public static func LDL<T>(_ a: Mat<T>, triangle: TriangularType = .lower) -> (L: Mat<T>, D: Mat<T>)
  where T: SwivlFloatingPoint {
    precondition(a.shape.r == a.shape.c, "Only square matrices are supported")
    var uplo = triangle.rawValue
    var n = __CLPK_integer(a.shape.r)
    var lda = __CLPK_integer(a.shape.r)
    var out = transpose(a)
    var ipiv = [__CLPK_integer](repeating: 0, count: a.shape.r)
    var lwork = __CLPK_integer(2*a.shape.r*a.shape.c)
    var info = __CLPK_integer()

    if T.self is Double.Type {
      var work = [Double](repeating: 0, count: Int(lwork))
      out.flat.withUnsafeMutableBufferPointer(as: Double.self) { p in
        dsytrf_(&uplo, &n, p.baseAddress!, &lda, &ipiv, &work, &lwork, &info)
      }
    } else {
      var work = [Float](repeating: 0, count: Int(lwork))
      out.flat.withUnsafeMutableBufferPointer(as: Float.self) { p in
        ssytrf_(&uplo, &n, p.baseAddress!, &lda, &ipiv, &work, &lwork, &info)
      }
    }
    out = transpose(out)
    //  TODO: Parse output
    print(out)
    print(ipiv)
    return (([],(0,0)), ([],(0,0)))
  }

}

