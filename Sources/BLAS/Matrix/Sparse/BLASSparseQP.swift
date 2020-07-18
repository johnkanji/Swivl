//  BLASMatrixQP.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import OSQP

extension BLAS {

  public static func OSQP(
    _ Q: [Double], _ shapeQ: RowCol, _ q: [Double],
    _ A: [Double], _ shapeA: RowCol, _ l: [Double], _ u: [Double]
  ) -> [Double] {
    precondition(shapeQ.r == shapeQ.c && shapeQ.r == shapeA.c)

    let n = c_int(shapeQ.r)
    let m = c_int(shapeA.c)
    var q = q
    var l = l
    var u = u

    let (U, _) = triangle(Q, shapeQ, .upper)
    var (iQ,jQ,vQ) = denseToCSC(U, shapeQ)
    var iQ2 = iQ.map(c_int.init)
    var jQ2 = jQ.map(c_int.init)
    let Q_csc = csc_matrix(m, n, c_int(vQ.count), &vQ, &iQ2, &jQ2)

    var (iA,jA,vA) = denseToCSC(A, shapeA)
    var iA2 = iA.map(c_int.init)
    var jA2 = jA.map(c_int.init)
    let A_csc = csc_matrix(m, n, c_int(vA.count), &vA, &iA2, &jA2)

    var work: UnsafeMutablePointer<OSQPWorkspace>? = UnsafeMutablePointer<OSQPWorkspace>.allocate(capacity: 0)
    let settings = UnsafeMutablePointer<OSQPSettings>.allocate(capacity: 1)
    let data: UnsafeMutablePointer<OSQPData> = q.withUnsafeMutableBufferPointer { pq in
    l.withUnsafeMutableBufferPointer { pl in
    u.withUnsafeMutableBufferPointer { pu in
      let data = UnsafeMutablePointer<OSQPData>.allocate(capacity: 1)
      data.pointee.m = m
      data.pointee.n = n
      data.pointee.P = Q_csc
      data.pointee.A = A_csc
      data.pointee.q = pq.baseAddress!
      data.pointee.l = pl.baseAddress!
      data.pointee.u = pu.baseAddress!
      return data
    }}}

    osqp_set_default_settings(settings)
    _ = osqp_setup(&work, data, settings)
    osqp_solve(work)

    let out = Array(UnsafeMutableBufferPointer(start: work?.pointee.solution.pointee.x, count: Int(n)))

    osqp_cleanup(work)
    data.pointee.P.deallocate()
    data.pointee.A.deallocate()
    data.deallocate()
    settings.deallocate()

    return out
  }

}
