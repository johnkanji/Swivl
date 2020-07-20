//  QR.swift
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

  public static func QR<T>(_ a: Mat<T>) -> (Q: Mat<T>, R: Mat<T>) where T: SwivlFloatingPoint {
    var m1 = __CLPK_integer(a.shape.r)
    var m2 = __CLPK_integer(a.shape.r)
    var n = __CLPK_integer(a.shape.c)
    var k = __CLPK_integer(a.shape.c)
    var lda = __CLPK_integer(a.shape.r)
    var lwork = __CLPK_integer(100*a.shape.c)
    var info = __CLPK_integer()
    var out = transpose(a)
    var tau = [T](repeating: 0, count: Swift.min(a.shape.r, a.shape.c))
    var work = [T](repeating: 0, count: Int(lwork))

    if T.self is Double.Type {
      out.flat.withUnsafeMutableBufferPointer(as: Double.self) { pO in
        tau.withUnsafeMutableBufferPointer(as: Double.self) { pT in
          work.withUnsafeMutableBufferPointer(as: Double.self) { pW in
            dgeqrf_(&m1, &n, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
            dorgqr_(&m1, &m2, &k, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
          }}}
    } else {
      out.flat.withUnsafeMutableBufferPointer(as: Float.self) { pO in
        tau.withUnsafeMutableBufferPointer(as: Float.self) { pT in
          work.withUnsafeMutableBufferPointer(as: Float.self) { pW in
            sgeqrf_(&m1, &n, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
            sorgqr_(&m1, &m2, &k, pO.baseAddress!, &lda, pT.baseAddress!, pW.baseAddress!, &lwork, &info)
          }}}
    }
    out = transpose(out)
    let Q = block(out, startIndex: (0,0), shapeOut: (a.shape.r, a.shape.r))
    let R = triangle(out, .upper)
    return (Q, R)
  }

}

