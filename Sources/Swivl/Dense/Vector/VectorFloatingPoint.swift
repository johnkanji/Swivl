//  VectorFloatingPoint.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Vector: RealVector where Scalar: AccelerateFloatingPoint {

  //  MARK: Vector Properties

  public var length: Scalar {
    BLAS.length(array)
  }
  public var norm: Scalar { self.length }


//  MARK: Unary Operators

  public func mean() -> Scalar {
    BLAS.mean(array)
  }

  
//  MARK: Binary Operators
//  Overrides
  
  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.subtract(lhs.array, rhs.array))
  }

  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.multiplyElementwise(lhs.array, rhs.array))
  }
  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(BLAS.multiplyScalar(lhs.array, rhs))
  }

  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    BLAS.dot(lhs.array, rhs.array)
  }


//  MARK: Geometry
  
  public static func dist(_ lhs: Self, _ rhs: Self) -> Scalar {
    BLAS.dist(lhs.array, rhs.array)
  }


//  MARK: Vector Creation
  
  /// Create a vector linearly interpolating the given bounds inclusively.
  ///
  /// - Parameters:
  ///    - start: lower bound
  ///    - stop: upper bound
  ///    - count: number of elements
  /// - Returns: ones vector of specified size
  public static func linear(_ start: Scalar, _ stop: Scalar, _ count: Int) -> Self {
    Self(BLAS.linear(start, stop, count))
  }

  public static func rand(_ count: Int) -> Self {
    Self(BLAS.rand(count))
  }

  public static func randn(_ count: Int) -> Self {
    Self(BLAS.randn(count))
  }

}
