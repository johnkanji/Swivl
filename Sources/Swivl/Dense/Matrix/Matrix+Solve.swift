//  Matrix+Solve.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Matrix where Scalar: SwivlFloatingPoint {

  public func solveTriangular(_ b: Self) throws -> Self {

    if self.isLowerTringular {
      return try Self(LinAlg.solveTriangular(_mat, b._mat, .lower))
    }
    if self.isUpperTriangular {
      return try Self(LinAlg.solveTriangular(_mat, b._mat, .upper))
    }
    throw LinAlgError.invalidMatrix("Not a triangular matrix")
  }
  public func solveTriangular(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try self.solveTriangular(b.matrix()).vector()
  }


  public func solveCholesky(_ b: Self) throws -> Self {
    try Self(LinAlg.solveCholesky(_mat, b._mat))
  }
  public func solveCholesky(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try self.solveCholesky(b.matrix()).vector()
  }


  public func solveLDL(_ b: Self) throws -> Self {
    try Self(LinAlg.solveLDL(_mat, b._mat))
  }
  public func solveLDL(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try self.solveLDL(b.matrix()).vector()
  }


  public func solveLU(_ b: Self) throws -> Self {
    try Self(LinAlg.solveLU(_mat, b._mat))
  }
  public func solveLU(_ b: Vector<Scalar>) throws -> Vector<Scalar> {
    try self.solveLU(b.matrix()).vector()
  }


  public func leastSquares(_ b: Self) -> Self {
    Self(LinAlg.leastSquares(_mat, b._mat))
  }
  public func leastSquares(_ b: Vector<Scalar>) -> Vector<Scalar> {
    self.leastSquares(b.matrix()).vector()
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
