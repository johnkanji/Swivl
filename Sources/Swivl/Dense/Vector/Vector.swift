//  Vector.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

public struct Vector<Scalar>: VectorProtocol where Scalar: AccelerateNumeric {

  public typealias Element = Scalar
  public typealias Index = Array<Scalar>.Index

  public var array: [Element]
  var layout: MatrixLayout = .columnMajor
  
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

  init(_ v: [Scalar], _ layout: MatrixLayout) {
    switch layout {
    case .rowMajor:
      self.init(row: v)
    default:
      self.init(column: v)
    }
  }
  
  public init(row: [Scalar]) {
    self.init(row)
    self.layout = .rowMajor
  }
  
  public init(column: [Scalar]) {
    self.init(column)
  }
  
  public init(_ array: [Scalar], shape: RowCol) {
    precondition(shape.r == 1 || shape.c == 1)
    self.array = array
    self.layout = shape.r == 1 ? .rowMajor : .columnMajor
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
    M(flat: BLAS.diag(array), shape: (count, count))
  }

  public var reversed: Self {
    Self(BLAS.reverse(self.array))
  }


  //  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    Self(lhs.array.map { x in -x }, lhs.layout)
  }

  public func abs() -> Self {
    Self(BLAS.abs(array), layout)
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
    array.sum()
  }

  public func mean<R>() -> R where R: AccelerateFloatingPoint {
    self.to(type: R.self).mean()
  }

  public func square() -> Self {
    Self(array.map { $0*$0 }, layout)
  }

  
//  MARK: Arithmetic

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.add(lhs.array, rhs.array))
  }
  public static func add(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(BLAS.addScalar(lhs.array, rhs))
  }

  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    lhs + (-rhs)
  }
  public static func subtract(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(BLAS.subtractScalar(lhs.array, rhs))
  }

  public static func multiply(_ lhs: Self, _ rhs: Self) -> Self {
    Self(zip(lhs.array, rhs.array).map { l, r in l * r })
  }
  public static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(lhs.array.map { l in l * rhs })
  }

  public static func divide(_ lhs: Self, _ rhs: Self) -> Self {
    Self(BLAS.divideElementwise(lhs.array, rhs.array))
  }
  public static func divide(_ lhs: Self, _ rhs: Scalar) -> Self {
    Self(BLAS.divideScalar(lhs.array, rhs))
  }


  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    return zip(lhs, rhs).map{ l, r -> Scalar in l*r }.sum()
  }


//  MARK: Vector Creation
  
  public static func zeros(_ count: Int) -> Self {
    return Self([Scalar].init(repeating: 0, count: count))
  }
  
  public static func ones(_ count: Int) -> Self {
    return Self([Scalar].init(repeating: 1, count: count))
  }


//  MARK: Conversions

  public func matrix() -> Matrix<Scalar> {
    Matrix(flat: array, shape: RowCol(rows, cols))
  }

  public func to<U>(type: U.Type) -> Vector<U> where U: AccelerateNumeric {
    Vector<U>(BLAS.toType(array, type), layout)
  }
  
}
