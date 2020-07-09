//  VectorFloatingPoint.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import BLAS

extension Vector: RealVector where Element: AccelerateFloatingPoint {
  
  public var length: T {
    BLAS.length(array)
  }
  
//  MARK: Vector-Vector Arithmetic
  
  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.subtract(lhs.array, rhs.array))
  }
  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.multiplyElementwise(lhs.array, rhs.array))
  }
  public static func divide(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.divideElementwise(lhs.array, rhs.array))
  }
  public static func dot(_ lhs: Self, _ rhs: Self) -> Element {
    BLAS.dot(lhs.array, rhs.array)
  }
  
  public static func dist(_ lhs: Self, _ rhs: Self) -> Element {
    BLAS.dist(lhs.array, rhs.array)
  }

//  MARK: Vector Generation
  
  /// Create a vector linearly interpolating the given bounds inclusively.
  ///
  /// - Parameters:
  ///    - start: lower bound
  ///    - stop: upper bound
  ///    - count: number of elements
  /// - Returns: ones vector of specified size
  public static func linear(_ start: Element, _ stop: Element, _ count: Int) -> Self {
    Self(BLAS.linear(start, stop, count))
  }
  public static func rand(_ count: Int) -> Self {
    Self(BLAS.rand(count))
  }
  public static func randn(_ count: Int) -> Self {
    Self(BLAS.randn(count))
  }
  
  
//  MARK: Approximate Equatable
  
  static func ==~ (lhs: Self, rhs: Self) -> Bool
  {
    return lhs.count == rhs.count &&
      zip(lhs.array, rhs.array).allSatisfy { (l, r) in l ==~ r }
  }
  
  static func !=~ (lhs: Self, rhs: Self) -> Bool
  {
    return !(lhs ==~ rhs)
  }
  
  /// Check if two vectors are equal using approximate comparison
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs ==~ rhs
  }
  
  /// Check if two vectors are not equal using approximate comparison
  public static func != (lhs: Self, rhs: Self) -> Bool {
    return lhs !=~ rhs
  }

}
