//  SparseMatrixFloatingPoint.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension SparseMatrix: RealMatrix where Scalar: SwivlFloatingPoint {

//  MARK: Matrix Properties

  var det: Scalar {
    0
  }

  var cond: Scalar {
    0
  }

  var rank: Int {
    0
  }

  mutating func isDefinite() -> Bool {
    false
  }

  func inv() -> SparseMatrix<Scalar> {
    Self()
  }

  func pinv() -> SparseMatrix<Scalar> {
    Self()
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    var out = Self(lhs._spmat)
    out._values = LinAlg.negate(lhs._values)
    return out
  }

  public func mean() -> Scalar {
    _values.sum() / Scalar(count)
  }

  public func square() -> SparseMatrix<Scalar> {
    var out = Self(_spmat)
    out._values = LinAlg.square(_values)
    return out
  }


//  MARK: Arithmetic

  public static func multiplyElements(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self.init(
      rowIndices: lhs._rowIndices,
      columnStarts: lhs._columnStarts,
      LinAlg.multiplyScalar(lhs._values, rhs),
      lhs.rows, lhs.cols)
  }


//  MARK: Matrix Creation

  public static func rand(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self(LinAlg.sparseRand(rows, cols))
  }

  public static func randn(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self(LinAlg.sparseRandn(rows, cols))
  }

}
