//  SIMD+VectorProtocol.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS
import simd

extension SIMD where Scalar: AccelerateFloatingPoint {

  public init(_ array: [Scalar], shape: RowCol) { self.init(array) }


  public func maxIndex() -> Int? {
    let m = self.max()
    for i in 0..<self.scalarCount {
      if self[i] == m { return i }
    }
    return nil
  }

  public func minIndex() -> Int? {
    let m = self.min()
    for i in 0..<self.scalarCount {
      if self[i] == m { return i }
    }
    return nil
  }


  //  MARK: Arithmetic

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    lhs + rhs
  }

  public static func add(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs + rhs
  }

  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    lhs - rhs
  }

  public static func subtract(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs - rhs
  }

  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    lhs * rhs
  }

  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs * rhs
  }

  public static func divide(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs / rhs
  }


  //  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    -lhs
  }

  public func square() -> Self {
    self*self
  }


  //  MARK: Vector Generation

  public static func zeros(_ count: Int) -> Self {
    Self.zero
  }

  public static func ones(_ count: Int) -> Self {
    Self.one
  }

}
