//  Matrix+Concatenation.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import BLAS

extension Matrix {
  
  public static func hcat(_ matrices: Matrix<T>...) -> Matrix<T> {
    let shape = RowCol(matrices[0].shape.r, matrices.map { m in m.shape.c }.sum())
    return Self.init(flat: BLAS.hcat(matrices.map(\.flat), shapes: matrices.map(\.shape)), shape: shape)
  }
  
  public static func vcat(_ matrices: Matrix<T>...) -> Matrix<T> {
    let shape = RowCol(matrices.map { m in m.shape.r }.sum(), matrices[0].shape.c)
    return Self.init(flat: BLAS.vcat(matrices.map(\.flat), shapes: matrices.map(\.shape)), shape: shape)
  }
  
  public static func || (_ lhs: Self, _ rhs: Self) -> Self {
    vcat(lhs, rhs)
  }
  
}
