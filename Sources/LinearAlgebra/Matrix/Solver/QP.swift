//  QP.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

  public static func OSQP(
    _ Q: Mat<Double>, _ q: [Double],
    _ A: Mat<Double>, _ l: [Double], _ u: [Double]
  ) -> [Double] {
    precondition(Q.shape.r == Q.shape.c && Q.shape.r == A.shape.c)

    let spQ = denseToCSC(Q)
    let spA = denseToCSC(A)
    return LinAlg.OSQP(spQ, q, spA, l, u)
  }

}
