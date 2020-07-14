//  VectorProtocol.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS


public protocol VectorProtocol: Collection, Equatable where Scalar: Numeric {
  typealias Scalar = Element

//  MARK: Initializers

  init()

  init(_ v: [Scalar])
  init(row: [Scalar])

  init(column: [Scalar])

  init(_ array: [Scalar], shape: RowCol)


//  MARK: Manipulation

  func diag<M>() -> M where M: MatrixProtocol, M.Scalar == Scalar


//  MARK: Unary Operators

  /// Negation of vector.
  ///
  /// Alternatively, `negate(a)` can be executed with `-a`.
  ///
  /// - Parameters
  ///     - lhs: vector
  /// - Returns: vector of negated values of elements of vector a
  static func negate(_ lhs: Self) -> Self

  func abs() -> Self

  func max() -> Scalar?
  func maxIndex() -> Int?

  func min() -> Scalar?
  func minIndex() -> Int?

  func sum() -> Scalar

  func square() -> Self


// MARK: Vector-Vector Arithmetic

  /// Perform vector addition.
  ///
  /// Alternatively, `add(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector sum of a and b
  static func add(_ lhs: Self , _ rhs: Self) -> Self

  
  /// Perform vector subtraction.
  ///
  /// Alternatively, `subtract(lhs, rhs)` can be executed with `a - b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector difference of a and b
  static func subtract(_ lhs: Self, _ rhs: Self) -> Self

  
  /// Perform vector multiplication.
  ///
  /// Alternatively, `multiply(lhs, rhs)` can be executed with `a .* b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector product of a and b
  static func multiply(_ lhs: Self, _ rhs: Self) -> Self

  
  /// Perform vector dot product operation.
  ///
  /// Alternatively, `dot(lhs, rhs)` can be executed with `a * b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: dot product of a and b
  static func dot(_ lhs: Self, _ rhs: Self) -> Scalar


  // MARK: - Vector-Scalar Arithmetic

  /// Perform vector and scalar addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `add(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise sum of vector a and scalar b
  static func add(_ lhs: Self, _ rhs: Scalar) -> Self

  
  /// Perform vector and scalar subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector subtraction is performed.
  ///
  /// Alternatively, `subtract(lhs, rhs)` can be executed with `a - b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise difference of vector a and scalar b
  static func subtract(_ lhs: Self, _ rhs: Scalar) -> Self


  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `multiply(lhs, rhs)` can be executed with `a .* b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func multiply(_ lhs: Self, _ rhs: Scalar) -> Self


  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `divide(lhs, rhs)` can be executed with `a ./ b`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func divide(_ lhs: Self, _ rhs: Scalar) -> Self

  
// MARK: Vector Creation
  
  /// Create a vector of zeros.
  ///
  /// - Parameters:
  ///    - count: number of elements
  /// - Returns: zeros vector of specified size
  static func zeros(_ count: Int) -> Self

  /// Create a vector of ones.
  ///
  /// - Parameters:
  ///    - count: number of elements
  /// - Returns: ones vector of specified size
  static func ones(_ count: Int) -> Self
  
}




//  MARK: Default Implementations

extension VectorProtocol {

  public init(row: [Scalar]) {
    self.init(row, shape: RowCol(1, row.count))
  }

  public init(column: [Scalar]) {
    self.init(column, shape: RowCol(column.count, 1))
  }

  public var startIndex: Int { 0 }
  public var endIndex: Int { self.count }

  public func index(after i: Int) -> Int {
    precondition(i >= startIndex && i < endIndex)
    return i+1
  }


  static func add(_ a: Scalar, _ b: Self) -> Self {
    return Self.add(b, a)
  }

  static func subtract(_ a: Scalar, _ b: Self) -> Self {
    return Self.negate(Self.subtract(b, a))
  }

  static func multiply(_ a: Scalar, _ b: Self) -> Self {
    return Self.multiply(b, a)
  }

  
  // MARK: - Operators: Vector-Vector

  /// Perform vector addition.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector sum of a and b
  static func + (_ lhs: Self , _ rhs: Self) -> Self {
    Self.add(lhs, rhs)
  }

  
  /// Perform vector subtraction.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector difference of a and b
  static func - (_ lhs: Self, _ rhs: Self) -> Self {
    Self.subtract(lhs, rhs)
  }

  
  /// Perform vector multiplication.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector product of a and b
  static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }

  
  /// Perform vector dot product operation.
  ///
  /// Alternatively, `a * b` can be executed with `dot(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: dot product of a and b
  static func * (_ lhs: Self, _ rhs: Self) -> Scalar {
    Self.dot(lhs, rhs)
  }
  
  
//  MARK: Operators: Vector-Scalar

  /// Perform vector and scalar addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise sum of vector a and scalar b
  static func + (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.add(lhs, rhs)
  }
  /// Perform scalar and vector addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a + b` can be executed with `add(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise sum of scalar a and vector b
  static func + (_ lhs: Scalar, _ rhs: Self) -> Self {
    Self.add(lhs, rhs)
  }

  
  /// Perform vector and scalar subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector subtraction is performed.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise difference of vector a and scalar b
  static func - (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.subtract(lhs, rhs)
  }
  /// Perform scalar and vector subtraction.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `a - b` can be executed with `subtract(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise difference of scalar a and vector b
  static func - (_ lhs: Scalar, _ rhs: Self) -> Self {
    Self.subtract(lhs, rhs)
  }

  
  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func .* (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform scalar and vector multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a .* b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise product of scalar a and vector b
  static func .* (_ lhs: Scalar, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform vector and scalar multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a * b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: elementwise product of vector a and scalar b
  static func * (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.multiply(lhs, rhs)
  }
  /// Perform scalar and vector multiplication.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector multiplication is performed.
  ///
  /// Alternatively, `a * b` can be executed with `multiply(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise product of scalar a and vector b
  static func * (_ lhs: Scalar, _ rhs: Self) -> Self {
    Self.multiply(lhs, rhs)
  }

  
  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `a ./ b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func ./ (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.divide(lhs, rhs)
  }
  /// Perform vector and scalar right division.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector right division is performed.
  ///
  /// Alternatively, `a / b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  ///     - rhs: scalar
  /// - Returns: result of elementwise division of vector a by scalar b
  static func / (_ lhs: Self, _ rhs: Scalar) -> Self {
    Self.divide(lhs, rhs)
  }


  /// Negation of vector.
  ///
  /// Alternatively, `-a` can be executed with `negate(a)`.
  ///
  /// - Parameters
  ///     - lhs: vector
  /// - Returns: vector of negated values of elements of vector a
  static prefix func - (_ lhs: Self) -> Self {
    Self.negate(lhs)
  }
}
