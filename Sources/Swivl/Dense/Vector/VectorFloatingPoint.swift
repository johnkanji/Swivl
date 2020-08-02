//  VectorFloatingPoint.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Vector: RealVector where Scalar: SwivlFloatingPoint {

//  MARK: Unary Operators

  public var length: Scalar { sqrt(self.squaredLength) }

  public func mean() -> Scalar {
    LinAlg.mean(array)
  }

  
//  MARK: Binary Operators
//  Overrides
  
  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.subtract(lhs.array, rhs.array))
  }

  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.multiplyElementwise(lhs.array, rhs.array))
  }
  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(LinAlg.multiplyScalar(lhs.array, rhs))
  }

  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    LinAlg.dot(lhs.array, rhs.array)
  }


//  MARK: Geometric Operations
  
  public static func dist(_ lhs: Self, _ rhs: Self) -> Scalar {
    sqrt(LinAlg.dist(lhs.array, rhs.array))
  }

  public static func normalize(_ v: Self) -> Self {
    v ./ v.length
  }

//  TODO: STUB
  public static func project(_ a: Self, onto b: Self) -> Self {
    Self()
  }

//  TODO: STUB
  public static func cross(_ a: Vector<Scalar>, _ b: Vector<Scalar>) -> Vector<Scalar> {
    precondition(a.count == 3 && b.count == 3)
    return Self()
  }
  public func cross(_ v: Self) -> Self { Self.cross(self, v) }



//  MARK: Vector Creation
  
  /// Create a vector linearly interpolating the given bounds inclusively.
  ///
  /// - Parameters:
  ///    - start: lower bound
  ///    - stop: upper bound
  ///    - count: number of elements
  /// - Returns: ones vector of specified size
  public static func linear(_ start: Scalar, _ stop: Scalar, _ count: Int) -> Self {
    Self(LinAlg.linear(start, stop, count))
  }

  public static func rand(_ count: Int) -> Self {
    Self(LinAlg.rand(count))
  }

  public static func randn(_ count: Int) -> Self {
    Self(LinAlg.randn(count))
  }

}
