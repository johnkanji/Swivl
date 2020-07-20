//  SparseMatrix+Solve.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension SparseMatrix where Scalar: SwivlFloatingPoint {

  public func solveLDL(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let flat = LinAlg.solveSparseQR(_spmat, b._flat)
    return Matrix(flat: flat, shape: b.shape)
  }

  public func solveLU(_ b: Matrix<Scalar>) -> Matrix<Scalar> {
    let flat = LinAlg.solveLU(_spmat, b._flat)
    return Matrix(flat: flat, shape: b.shape)
  }

}
