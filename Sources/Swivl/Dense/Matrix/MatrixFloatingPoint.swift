//  MatrixFloatingPoint.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Matrix: RealMatrix where Scalar: SwivlFloatingPoint {

//  MARK: Matrix Properties

  public var det: Scalar {
    LinAlg.det(_mat)
  }

  public var cond: Scalar {
    (try? LinAlg.cond(_mat)) ?? Scalar.nan
  }

  public var rank: Int {
    let (_, U) = self.LU()
    return U.rowwise { $0.sum() }.array.filter { Swift.abs($0) > Scalar.approximateEqualityTolerance }.count
  }

  public mutating func isDefinite() -> Bool {
    guard let definite = _definite else {
      _definite = (try? self.chol()) != nil
      return _definite!
    }
    return definite
  }


//  MARK: Initializers:

  public init(_ m: SparseMatrix<Scalar>) {
    self.init(LinAlg.CSCToDense(m._spmat))
  }


  //  MARK: Unary Operators

  // Override
  public static func negate(_ lhs: Self) -> Self {
    Self(flat: LinAlg.negate(lhs._flat), shape: lhs.shape)
  }

  public func mean() -> Scalar {
    LinAlg.mean(_flat)
  }

  // Override
  public func square() -> Self {
    return Self(flat: LinAlg.square(_flat), shape: shape)
  }

// TODO: STUB
  public func inv() -> Self {
    Self(LinAlg.inverse(_mat))
  }

  // TODO: STUB
  public func pinv() -> Self {
    return Self()
  }


  //  MARK: Arithmetic
  // Overrides (operators must be overriden too or the original implementation will be called)

  public static func multiplyElements(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: LinAlg.multiplyElementwise(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func multiplyElements(_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: LinAlg.multiplyScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiplyElements(lhs, rhs)
  }
  public static func * (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiplyElements(lhs, rhs)
  }
  public static func .* (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiplyElements(lhs, rhs)
  }

  public static func multiplyMatrix(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.multiplyMatrix(lhs._mat, rhs._mat))
  }
  public static func * (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiplyMatrix(lhs, rhs)
  }

  public static func multiplyMatrixVector(_ lhs: Self, _ rhs: Vector<Scalar>) -> Vector<Scalar> {
    Vector(LinAlg.multiplyMatrixVector(lhs._mat, rhs.array))
  }
  public static func multiplyMatrixVector(_ lhs: Vector<Scalar>, _ rhs: Self) -> Vector<Scalar> {
    Vector(LinAlg.multiplyMatrixVector(rhs._mat, lhs.array))
  }
  public static func * (_ lhs: Self, _ rhs: Vector<Scalar>) -> Vector<Scalar> {
    Vector(LinAlg.multiplyMatrixVector(lhs._mat, rhs.array))
  }
  public static func * (_ lhs: Vector<Scalar>, _ rhs: Self) -> Vector<Scalar> {
    Vector(LinAlg.multiplyMatrixVector(rhs._mat, lhs.array))
  }

  //  MARK: Matrix Creation

  public static func rand(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: LinAlg.rand(rows*cols), shape: (rows, cols))
  }

  public static func randn(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: LinAlg.randn(rows*cols), shape: (rows, cols))
  }


  //  MARK: Decompositions

  public func chol(_ triangle: TriangularType = .upper) throws -> Self {
    try Self(LinAlg.chol(_mat, triangle: triangle))
  }

  public func LU() -> (L: Self, U: Self) {
    let (L, U, _, _) = self.LU(.LU)
    return (L, U)
  }

  public func LU(_ output: LUOutput) -> (L: Self, U: Self, P: Self?, Q: Self?) {
    switch output {
    case .LU:
      let (L, U, _, _) = LinAlg.LU(_mat, output: output)
      return (L: Self(L), U: Self(U), nil, nil)
    case .LUP:
      let (L, U, P, _) = LinAlg.LU(_mat, output: output)
      return (L: Self(L), U: Self(U), P: Self(P!), nil)
    case .LUPQ:
      let (L, U, P, Q) = LinAlg.LU(_mat, output: output)
      return (L: Self(L), U: Self(U), P: Self(P!), Q: Self(Q!))
    }
  }

  public func LDL(_ triangle: TriangularType) -> (L: Self, D: Self) {
    let (L, D) = LinAlg.LDL(_mat)
    return (Self(L), Self(D))
  }

  public func QR() -> (Q: Self, R: Self) {
    let (Q, R) = LinAlg.QR(_mat)
    return (Self(Q), Self(R))
  }

  public func eig<VR>(vectors: SingularVectorOutput = .none) -> (values: VR, leftVectors: Self?, rightVectors: Self?)
  where VR: VectorProtocol, VR.Scalar == Scalar {
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both

    let (V, DL, DR) = try! LinAlg.eig(_mat, vectors: vectors)
    return (VR(V), left ? Self(DL!) : nil, right ? Self(DR!) : nil)
  }

  public func SVD<VR>(vectors: SingularVectorOutput = .none) -> (values: VR, leftVectors: Self?, rightVectors: Self?)
  where VR : VectorProtocol, VR.Scalar == Scalar {
    (VR(), nil, nil)
  }
  
}
