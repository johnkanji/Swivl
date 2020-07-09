//  Vector.swift
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import BLAS

public struct Vector<T>: VectorProtocol where T: AccelerateNumeric {
  public typealias Index = Array<T>.Index
  public typealias Element = T

  var array: [Element]
  var _layout: MatrixLayout = .columnMajor
  
  public var count: Int { array.count }
  public var startIndex: Index { array.startIndex }
  public var endIndex: Index { array.endIndex }

  public init() {
    array = []
  }

  public init(_ s: [T]) {
    array = s
  }
  
  public init(row: [T]) {
    self.init(row)
    self._layout = .rowMajor
  }
  
  public init(column: [T]) {
    self.init(column)
  }
  
  public init(_ array: [T], shape: RowCol) {
    precondition(shape.r == 1 || shape.c == 1)
    self.array = array
    self._layout = shape.r == 1 ? .rowMajor : .columnMajor
  }

  public subscript(position: Array<T>.Index) -> T {
    _read {
      yield array[position]
    }
  }

  public func index(after i: Array<T>.Index) -> Array<T>.Index {
    array.index(after: i)
  }
  
//  MARK: Vector-Vector Arithmetic

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.add(lhs.array, rhs.array))
  }
  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    lhs + (-rhs)
  }
  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(zip(lhs.array, rhs.array).map { l, r in l * r })
  }
  public static func divide(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.divideElementwise(lhs.array, rhs.array))
  }
  
//  MARK: Vector-Scalar Arithmetic
  
  public static func add(_ lhs: Self, _ rhs: T) -> Self {
    Self(BLAS.addScalar(lhs.array, rhs))
  }
  public static func subtract(_ lhs: Self, _ rhs: T) -> Self {
    Self(BLAS.subtractScalar(lhs.array, rhs))
  }
  public static func multiply(_ lhs: Self, _ rhs: T) -> Self {
    Self(lhs.array.map { l in l * rhs })
  }
  public static func divide(_ lhs: Self, _ rhs: T) -> Self {
    Self(BLAS.divideScalar(lhs.array, rhs))
  }
  public static func dot(_ lhs: Self, _ rhs: Self) -> Element {
    return zip(lhs, rhs).map{ l, r in l*r }.sum()
  }
  
  
//  MARK: Unary Arithmetic
  
  public static func negate(_ lhs: Vector<T>) -> Vector<T> {
    Self(lhs.array.map { -$0 })
  }


//  MARK: Vector Creation
  
  public static func zeros(_ count: Int) -> Self {
    return Self([T].init(repeating: 0, count: count))
  }
  
  public static func ones(_ count: Int) -> Self {
    return Self([T].init(repeating: 1, count: count))
  }
  
  
  public func reversed() -> Self {
    Self(BLAS.reverse(self.array))
  }
  
}
