//  SparseQP.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import OSQP

extension LinAlg {

  public static func OSQP(
    _ Q: SpMat<Double>, _ q: [Double], _ A: SpMat<Double>,
    _ l: [Double], _ u: [Double]) -> [Double] {
    precondition(Q.shape.r == Q.shape.c && Q.shape.r == A.shape.c)

    let n = c_int(Q.shape.r)
    let m = c_int(A.shape.c)
    var q = q
    var l = l
    var u = u

    var Q = Q
//    TODO:
//    let (U, _) = triangle(Q, Q.shape, .upper)
    var Qri = Q.ri.map(c_int.init)
    var Qcs = Q.cs.map(c_int.init)
    let Q_csc = csc_matrix(m, n, c_int(Q.v.count), &Q.v, &Qri, &Qcs)

    var A = A
    var Ari = A.ri.map(c_int.init)
    var Acs = A.cs.map(c_int.init)
    let A_csc = csc_matrix(m, n, c_int(A.v.count), &A.v, &Ari, &Acs)

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
