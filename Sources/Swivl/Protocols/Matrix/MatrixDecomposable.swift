//  MatrixDecomposable.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

protocol MatrixDecomposable: MatrixProtocol {

  func chol(_ triangle: TriangularType) throws -> Self

  func LU(_ output: LUOutput) -> (L: Self, U: Self, P: Self?, Q: Self?)

  func LDL(_ triangle: TriangularType) -> (L: Self, D: Self)

  func QR(_ triangle: TriangularType) -> Self

  func eig<V>(vectors: SingularVectorOutput) -> (values: V, leftVectors: Self?, rightVectors: Self?)
  where V: VectorProtocol, V.Element == Scalar

  func SVD<V>(vectors: SingularVectorOutput) -> (values: V, leftVectors: Self?, rightVectors: Self?)
  where V: VectorProtocol, V.Element == Scalar
  
}
