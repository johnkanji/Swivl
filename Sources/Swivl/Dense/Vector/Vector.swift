//  Vector.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

public struct Vector<Scalar>: VectorProtocol where Scalar: SwivlNumeric {
  public typealias Element = Scalar
  public typealias Index = Array<Scalar>.Index

  public var array: [Element]
  
  public var count: Int { array.count }
  public var startIndex: Index { array.startIndex }
  public var endIndex: Index { array.endIndex }


//  MARK: Initializers

  public init() {
    array = []
  }

  public init(_ v: [Scalar]) {
    array = v
  }


//  MARK: Subscripts

  public subscript(position: Index) -> Scalar {
    _read {
      yield array[position]
    }
  }

  public func index(after i: Index) -> Index {
    array.index(after: i)
  }


//  MARK: Manipulation

  public func diag<M>() -> M where M: MatrixProtocol, M.Scalar == Scalar {
    M(flat: LinAlg.diag(array).flat, shape: (count, count))
  }
  public func diag() -> Matrix<Scalar> {
    Matrix(LinAlg.diag(array))
  }

  public var reversed: Self {
    Self(LinAlg.reverse(self.array))
  }

  public static func & (_ lhs: Self, _ rhs: Self) -> Self {
    Self(lhs.array + rhs.array)
  }


  //  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    Self(LinAlg.negate(lhs.array))
  }

  public func abs() -> Self {
    Self(LinAlg.abs(array))
  }

  public func max() -> Scalar? {
    array.max()
  }
  public func maxIndex() -> Int? {
    guard let m = array.max() else { return nil }
    return array.firstIndex(of: m)
  }

  public func min() -> Scalar? {
    array.min()
  }
  public func minIndex() -> Int? {
    guard let m = array.min() else { return nil }
    return array.firstIndex(of: m)
  }

  public func sum() -> Scalar {
    LinAlg.sum(array)
  }

  public func mean<R>() -> R where R: SwivlFloatingPoint {
    self.to(type: R.self).mean()
  }

  public func square() -> Self {
    Self(LinAlg.square(array))
  }

  
//  MARK: Arithmetic

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.add(lhs.array, rhs.array))
  }
  public static func add(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(LinAlg.addScalar(lhs.array, rhs))
  }

  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.subtract(lhs.array, rhs.array))
  }
  public static func subtract(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(LinAlg.subtractScalar(lhs.array, rhs))
  }

  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.multiplyElementwise(lhs.array, rhs.array))
  }
  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(LinAlg.multiplyScalar(lhs.array, rhs))
  }

  public static func divide(_ lhs: Self, _ rhs: Self) -> Self {
    Self(LinAlg.divideElementwise(lhs.array, rhs.array))
  }
  public static func divide(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(LinAlg.divideScalar(lhs.array, rhs))
  }


  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    return LinAlg.dot(lhs.array, rhs.array)
  }


//  MARK: Vector Creation
  
  public static func zeros(_ count: Int) -> Self {
    return Self([Scalar].init(repeating: 0, count: count))
  }
  
  public static func ones(_ count: Int) -> Self {
    return Self([Scalar].init(repeating: 1, count: count))
  }


//  MARK: Conversions

  public func matrix(_ dim: MatrixDimension = .col) -> Matrix<Scalar> {
    Matrix(flat: array, shape: dim == .col ? (count, 1) : (1, count))
  }

  public func to<U>(type: U.Type) -> Vector<U> where U: SwivlNumeric {
    if U.self is Scalar.Type {
      return self as! Vector<U>
    } else {
      return Vector<U>(LinAlg.toType(array, type))
    }
  }
  
}
