//  MatrixFloatingPoint.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Matrix: RealMatrix where Scalar: AccelerateFloatingPoint {

//  MARK: Matrix Properties

  public var det: Scalar {
    BLAS.det(_flat, shape)
  }

  //  TODO: STUB
  public var cond: Scalar {
    0
  }

  public var rank: Int {
    let (_, U) = self.LU()
    return U.rowwise { $0.sum() }.array.filter { Swift.abs($0) > Scalar.approximateEqualityTolerance }.count
  }

  public var isDefinite: Bool {
    return (try? self.chol()) != nil
  }


  //  MARK: Unary Operators

  // Override
  public static func negate(_ lhs: Self) -> Self {
    Self(flat: BLAS.negate(lhs._flat), shape: lhs.shape)
  }

  public func mean() -> Scalar {
    BLAS.mean(_flat)
  }

  // Override
  public func square() -> Self {
    Self(flat: BLAS.square(_flat), shape: shape)
  }

// TODO: STUB
  public func inv() -> Self {
    return Self()
  }

  // TODO: STUB
  public func pinv() -> Self {
    return Self()
  }


  //  MARK: Arithmetic
  // Overrides

  public static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: BLAS.multiplyElementwise(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func .* (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.multiplyScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func .* (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: BLAS.multiplyScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  public static func * (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.multiplyScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func * (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: BLAS.multiplyScalar(rhs._flat, lhs), shape: rhs.shape)
  }


  public static func * (_ lhs: Self, _ rhs: Self) -> Self {
    let (c, shapeC) = BLAS.multiplyMatrix(lhs._flat, lhs.shape, rhs._flat, rhs.shape)
    return Self(flat: c, shape: shapeC)
  }


  //  MARK: Matrix Creation

  public static func rand(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: BLAS.rand(rows*cols), shape: (rows, cols))
  }

  public static func randn(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: BLAS.randn(rows*cols), shape: (rows, cols))
  }


  //  MARK: Decompositions

  public func chol(_ triangle: TriangularType = .upper) throws -> Self {
    try Self(flat: BLAS.chol(_flat, shape, triangle: triangle), shape: shape)
  }

  public func LU() -> (L: Self, U: Self) {
    let (L, U, _, _) = self.LU(.LU)
    return (L, U)
  }

  public func LU(_ output: LUOutput) -> (L: Self, U: Self, P: Self?, Q: Self?) {
    switch output {
    case .LU:
      let ((L, shapeL), (U, shapeU), _, _) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shapeL), U: Self(flat: U, shape: shapeU), nil, nil)
    case .LUP:
      let ((L, shapeL), (U, shapeU), P, _) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shapeL), U: Self(flat: U, shape: shapeU), P: Self(flat: P!, shape: shape), nil)
    case .LUPQ:
      let ((L, shapeL), (U, shapeU), P, Q) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shapeL), U: Self(flat: U, shape: shapeU),
              P: Self(flat: P!, shape: shape), Q: Self(flat: Q!, shape: shape))
    }
  }

  public func LDL(_ triangle: TriangularType) -> (L: Self, D: Self) {
    let (L, D) = BLAS.LDL(_flat, shape)
    return (Self(flat: L, shape: shape), Self(flat: D, shape: shape))
  }

  public func QR(_ triangle: TriangularType) -> Self {
    return Self()
  }

  public func eig<VR>(vectors: SingularVectorOutput = .none) -> (values: VR, leftVectors: Self?, rightVectors: Self?)
  where VR: VectorProtocol, VR.T == Scalar {
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both

    let (V, DL, DR) = try! BLAS.eig(_flat, shape, vectors: vectors)
    return (VR(row: V), left ? Self(flat: DL!, shape: shape) : nil, right ? Self(flat: DR!, shape: shape) : nil)
  }

  public func SVD<VR>(vectors: SingularVectorOutput = .none) -> (values: VR, leftVectors: Self?, rightVectors: Self?)
  where VR : VectorProtocol, VR.T == Scalar {
    (VR(), nil, nil)
  }
  
}
