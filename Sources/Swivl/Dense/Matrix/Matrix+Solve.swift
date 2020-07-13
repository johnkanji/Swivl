//  Matrix+Solve.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Matrix where Scalar: AccelerateFloatingPoint {

  public func solveTriangular(_ b: Self) throws -> Self {
    if self.isLowerTringular {
      return try Self(flat: BLAS.solveTriangular(_flat, shape, b._flat, b.shape, .lower), shape: b.shape)
    }
    if self.isUpperTriangular {
      return try Self(flat: BLAS.solveTriangular(_flat, shape, b._flat, b.shape, .upper), shape: b.shape)
    }
    throw BLASError.invalidMatrix("Not a triangular matrix")
  }
  public func solveTriangular(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try self.solveTriangular(b.matrix()).vector()
  }


  public func solveCholesky(_ b: Self) throws -> Self {
    try Self(flat: BLAS.solveCholesky(_flat, shape, b._flat, b.shape), shape: b.shape)
  }
  public func solveCholesky(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try Vector(BLAS.solveCholesky(_flat, shape, b.array, (b.count, 1)))
  }


  public func solveLDL(_ b: Self) throws -> Self {
    try Self(flat: BLAS.solveLDL(_flat, shape, b._flat, b.shape), shape: b.shape)
  }
  public func solveLDL(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try Vector(BLAS.solveLDL(_flat, shape, b.array, b.shape))
  }


  public func solveLU(_ b: Self) throws -> Self {
    try Self(flat: BLAS.solveLU(_flat, shape, b._flat, b.shape), shape: b.shape)
  }
  public func solveLU(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try Vector(BLAS.solveLU(_flat, shape, b.array, b.shape))
  }


  public func leastSquares(_ b: Self) -> Self {
    let shapeOut = cols > rows ? (rows, b.shape.c) : b.shape
    return Self(flat: BLAS.leastSquares(_flat, shape, b._flat, b.shape), shape: shapeOut)
  }
  public func leastSquares(_ b: Vector<Scalar>) -> Vector<Scalar> {
    Vector(BLAS.leastSquares(_flat, shape, b.array, (b.count, 1)))
  }


  public func solve(_ b: Matrix<Scalar>) throws -> Matrix<Scalar> {
    if !self.isSquare {
      return self.leastSquares(b)
    } else if let x = try? self.solveTriangular(b) {
      return x
    } else if self.isSymmetric {
      let d: [Scalar] = self.diag().array
      if d.filter({ i in i.sign == d.first!.sign }).count == d.count {
        if let x = try? self.solveCholesky(b) {
          return x
        } else {
          return try self.solveLDL(b)
        }
      } else {
        return try self.solveLDL(b)
      }
    } else {
      return try self.solveLU(b)
    }
  }

}
