//  SIMD+VectorProtocol.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra
import simd

extension SIMD where Scalar: SwivlFloatingPoint {
  public typealias Iterator = Array<Scalar>.Iterator

//  MARK: Vector Properties

  func _length() -> Scalar { (self*self).sum() }
  public var length: Scalar {
    _length()
  }


//  MARK: Initializers

  public init(_ array: [Scalar], shape: RowCol) {
    self.init(array)
  }


//  MARK: Iteration

  public func makeIterator() -> Iterator { array.makeIterator() }

  public var array: [Scalar] {
    (0..<Self.scalarCount).map { i in self[i] }
  }


//  MARK: Manipulation

  public func diag<M>() -> M where M : MatrixProtocol, Self.Scalar == M.Scalar {
    return M([])
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    -lhs
  }

  public func abs() -> Self {
    Self()
  }

  public func minIndex() -> Int? {
    0
  }
  public func maxIndex() -> Int? {
    0
  }

  public func mean() -> Scalar {
    0
  }

  public func square() -> Self {
    Self()
  }

  public func sum() -> Scalar {
    self.array.sum()
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
    lhs*rhs
  }
  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs*rhs
  }

  public static func divide(_ lhs: Self, _ rhs: Self) -> Self {
    lhs / rhs
  }
  public static func divide(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs / rhs
  }

  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    (lhs * rhs).sum()
  }

  public static func dist(_ a: Self, _ b: Self) -> Scalar {
    0
  }


//  MARK: Vector Creation

  public static func zeros(_ count: Int) -> Self {
    Self()
  }

  public static func ones(_ count: Int) -> Self {
    Self()
  }

  public static func linear(_ start: Scalar, _ stop: Scalar, _ count: Int) -> Self {
    Self()
  }

  public static func rand(_ count: Int) -> Self {
    Self()
  }

  public static func randn(_ count: Int) -> Self {
    Self()
  }

}
