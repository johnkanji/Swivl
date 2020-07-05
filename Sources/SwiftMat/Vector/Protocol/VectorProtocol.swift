////
////  VectorProtocol.swift
////
////
////  Created by John Kanji on 2020-Jul-03.
////
//
//import Foundation
//import Accelerate
//
//
//public protocol VectorProtocol where Element: Numeric {
//  associatedtype Element
//
//  // MARK: - Arithmetic operations on two vectors
//
//  /// Perform vector addition.
//  ///
//  /// Alternatively, `plus(lhs, rhs)` can be executed with `a + b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector sum of a and b
//  static func plus(_ lhs: Self , _ rhs: Self) -> Self
//
//  /// Perform vector substraction.
//  ///
//  /// Alternatively, `minus(lhs, rhs)` can be executed with `a - b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector difference of a and b
//  static func minus(_ lhs: Self, _ rhs: Self) -> Self
//
//  /// Perform vector multiplication.
//  ///
//  /// Alternatively, `times(lhs, rhs)` can be executed with `a .* b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector product of a and b
//  static func times(_ lhs: Self, _ rhs: Self) -> Self
//
//
//  /// Perform vector right division.
//  ///
//  /// Alternatively, `rdivide(lhs, rhs)` can be executed with `a ./ b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of a by b
//  static func rdivide(_ lhs: Self, _ rhs: Self) -> Self
//
//
//  /// Perform vector left division.
//  ///
//  /// Alternatively, `ldivide(lhs, rhs)` can be executed with `a ./. b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of b by a
//  static func ldivide(_ lhs: Self, _ rhs: Self) -> Self
//
//  // MARK: - Dot product operations on two vectors
//
//  /// Perform vector dot product operation.
//  ///
//  /// Alternatively, `dot(lhs, rhs)` can be executed with `a * b`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: dot product of a and b
//  static func dot(_ lhs: Self, _ rhs: Self) -> Element
//
//
//  // MARK: - Arithmetic operations on vector and scalar
//
//  /// Perform vector and scalar addition.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `plus(lhs, rhs)` can be executed with `a + b`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise sum of vector a and scalar b
//  static func plus<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric
//
//  /// Perform scalar and vector addition.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `plus(lhs, rhs)` can be executed with `a + b`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise sum of scalar a and vector b
//  static func plus<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//
//  /// Perform vector and scalar substraction.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector substraction is performed.
//  ///
//  /// Alternatively, `minus(lhs, rhs)` can be executed with `a - b`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise difference of vector a and scalar b
//  static func minus<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric
//
//  /// Perform scalar and vector substraction.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `minus(lhs, rhs)` can be executed with `a - b`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise difference of scalar a and vector b
//  static func minus<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//
//  /// Perform vector and scalar multiplication.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector multiplication is performed.
//  ///
//  /// Alternatively, `times(lhs, rhs)` can be executed with `a .* b`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise product of vector a and scalar b
//  static func times<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric
//
//  /// Perform scalar and vector multiplication.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector multiplication is performed.
//  ///
//  /// Alternatively, `times(lhs, rhs)` can be executed with `a .* b`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise product of scalar a and vector b
//  static func times<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//
//  /// Perform vector and scalar right division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector right division is performed.
//  ///
//  /// Alternatively, `rdivide(lhs, rhs)` can be executed with `a ./ b`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of vector a by scalar b
//  static func rdivide<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric
//
//  /// Perform scalar and vector right division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector right division is performed.
//  ///
//  /// Alternatively, `rdivide(lhs, rhs)` can be executed with `a ./ b`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of scalar a by vector b
//  static func rdivide<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//
//  /// Perform vector and scalar left division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector left division is performed.
//  ///
//  /// Alternatively, `ldivide(lhs, rhs)` can be executed with `a ./. b`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of scalar b by vector a
//  static func ldivide<Scalar>(_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric
//
//  /// Perform scalar and vector left division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector left division is performed.
//  ///
//  /// Alternatively, `ldivide(lhs, rhs)` can be executed with `a ./. b`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of vector b by scalar a
//  static func ldivide<Scalar>(_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric
//
//  // MARK: - Sign operations on vector
//
//  /// Absolute value of vector.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  /// - Returns: vector of absolute values of elements of vector a
//  func abs(_ lhs: Self) -> Self
//
//  /// Negation of vector.
//  ///
//  /// Alternatively, `uminus(a)` can be executed with `-a`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  /// - Returns: vector of negated values of elements of vector a
//  static func uminus(_ lhs: Self) -> Self
//
//  /// Threshold function on vector.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  /// - Returns: vector with values less than certain value set to 0
//  ///            and keeps the value otherwise
//  static func thr<Scalar>(_ lhs: Self, _ t: Scalar) -> Self where Scalar: Numeric
//
//  /// Create a vector of zeros.
//  ///
//  /// - Parameters:
//  ///    - count: number of elements
//  /// - Returns: zeros vector of specified size
//  static func zeros(_ count: Int) -> Self
//
//  /// Create a vector of ones.
//  ///
//  /// - Parameters:
//  ///    - count: number of elements
//  /// - Returns: ones vector of specified size
//  func ones(_ count: Int) -> Self
//
//  /// Create a vector of uniformly distributed on [0, 1) interval random values.
//  ///
//  /// - Parameters:
//  ///    - count: number of elements
//  /// - Returns: random values vector of specified size
//  static func rand(_ count: Int) -> Self
//
//  /// Create a vector of normally distributed  random values.
//  ///
//  /// - Parameters:
//  ///    - count: number of elements
//  /// - Returns: random values vector of specified size
//  static func randn(_ count: Int) -> Self
//}
//
//
//extension VectorProtocol {
//
//  static func plus(_ a: Element, _ b: Self) -> Self {
//    return Self.plus(b, a)
//  }
//
//  static func minus(_ a: Element, _ b: Self) -> Self {
//    return Self.uminus(Self.minus(b, a))
//  }
//
//  static func times(_ a: Element, _ b: Self) -> Self {
//    return Self.times(b, a)
//  }
//
//  static func ldivide(_ a: Self, _ b: Element) -> Self {
//    return Self.rdivide(b, a)
//  }
//
//  static func ldivide(_ a: Element, _ b: Self) -> Self {
//    return Self.rdivide(b, a)
//  }
//
//  // MARK: - Operators
//
//  /// Perform vector addition.
//  ///
//  /// Alternatively, `a + b` can be executed with `plus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector sum of a and b
//  static func + (_ lhs: Self , _ rhs: Self) -> Self {
//    Self.plus(lhs, rhs)
//  }
//
//  /// Perform vector substraction.
//  ///
//  /// Alternatively, `a - b` can be executed with `minus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector difference of a and b
//  static func - (_ lhs: Self, _ rhs: Self) -> Self {
//    Self.minus(lhs, rhs)
//  }
//
//  /// Perform vector multiplication.
//  ///
//  /// Alternatively, `a .* b` can be executed with `times(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: elementwise vector product of a and b
//  static func .* (_ lhs: Self, _ rhs: Self) -> Self {
//    Self.times(lhs, rhs)
//  }
//
//
//  /// Perform vector right division.
//  ///
//  /// Alternatively, `a ./ b` can be executed with `rdivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of a by b
//  static func ./ (_ lhs: Self, _ rhs: Self) -> Self {
//    Self.rdivide(lhs, rhs)
//  }
//
//  /// Perform vector left division.
//  ///
//  /// Alternatively, `a ./. b` can be executed with `ldivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: result of elementwise division of b by a
//  static func ./. (_ lhs: Self, _ rhs: Self) -> Self {
//    Self.ldivide(lhs, rhs)
//  }
//
//  /// Perform vector dot product operation.
//  ///
//  /// Alternatively, `a * b` can be executed with `dot(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: left vector
//  ///     - rhs: right vector
//  /// - Returns: dot product of a and b
//  static func * (_ lhs: Self, _ rhs: Self) -> Element {
//    Self.dot(lhs, rhs)
//  }
//
//  /// Perform vector and scalar addition.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `a + b` can be executed with `plus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise sum of vector a and scalar b
//  static func + <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.plus(lhs, rhs)
//  }
//
//  /// Perform scalar and vector addition.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `a + b` can be executed with `plus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise sum of scalar a and vector b
//  static func + <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.plus(lhs, rhs)
//  }
//
//  /// Perform vector and scalar substraction.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector substraction is performed.
//  ///
//  /// Alternatively, `a - b` can be executed with `minus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise difference of vector a and scalar b
//  static func - <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.minus(lhs, rhs)
//  }
//
//  /// Perform scalar and vector substraction.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector addition is performed.
//  ///
//  /// Alternatively, `a - b` can be executed with `minus(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise difference of scalar a and vector b
//  static func - <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.minus(lhs, rhs)
//  }
//
//  /// Perform vector and scalar multiplication.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector multiplication is performed.
//  ///
//  /// Alternatively, `a .* b` can be executed with `times(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: elementwise product of vector a and scalar b
//  static func .* <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.times(lhs, rhs)
//  }
//
//  /// Perform scalar and vector multiplication.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector multiplication is performed.
//  ///
//  /// Alternatively, `a .* b` can be executed with `times(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: elementwise product of scalar a and vector b
//  static func .* <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.times(lhs, rhs)
//  }
//
//  /// Perform vector and scalar right division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector right division is performed.
//  ///
//  /// Alternatively, `a ./ b` can be executed with `rdivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of vector a by scalar b
//  static func ./ <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.rdivide(lhs, rhs)
//  }
//
//  /// Perform scalar and vector right division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector right division is performed.
//  ///
//  /// Alternatively, `a ./ b` can be executed with `rdivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of scalar a by vector b
//  static func ./ <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.rdivide(lhs, rhs)
//  }
//  /// Perform vector and scalar left division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector left division is performed.
//  ///
//  /// Alternatively, `a ./. b` can be executed with `ldivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  ///     - rhs: scalar
//  /// - Returns: result of elementwise division of scalar b by vector a
//  static func ./. <Scalar> (_ lhs: Self, _ rhs: Scalar) -> Self where Scalar: Numeric {
//    Self.ldivide(lhs, rhs)
//  }
//  /// Perform scalar and vector left division.
//  ///
//  /// Scalar value expands to vector dimension
//  /// and elementwise vector left division is performed.
//  ///
//  /// Alternatively, `a ./. b` can be executed with `ldivide(lhs, rhs)`.
//  ///
//  /// - Parameters
//  ///     - lhs: scalar
//  ///     - rhs: vector
//  /// - Returns: result of elementwise division of vector b by scalar a
//  static func ./. <Scalar> (_ lhs: Scalar, _ rhs: Self) -> Self where Scalar: Numeric {
//    Self.ldivide(lhs, rhs)
//  }
//
//  /// Negation of vector.
//  ///
//  /// Alternatively, `-a` can be executed with `uminus(a)`.
//  ///
//  /// - Parameters
//  ///     - lhs: vector
//  /// - Returns: vector of negated values of elements of vector a
//  static prefix func - (_ lhs: Self) -> Self {
//    Self.uminus(lhs)
//  }
//}

public protocol VectorProtocol: Collection, Equatable where Element: Numeric {
  typealias Scalar = Numeric

  /// Perform vector addition.
  ///
  /// Alternatively, `plus(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: elementwise vector sum of a and b
  static func plus(_ lhs: Self, _ rhs: Self) -> Self

  /// Perform scalar and vector addition.
  ///
  /// Scalar value expands to vector dimension
  /// and elementwise vector addition is performed.
  ///
  /// Alternatively, `plus(lhs, rhs)` can be executed with `a + b`.
  ///
  /// - Parameters
  ///     - lhs: scalar
  ///     - rhs: vector
  /// - Returns: elementwise sum of scalar a and vector b
  static func plus(_ lhs: Element, _ rhs: Self) -> Self
  
}


extension VectorProtocol {
  public static func + (_ lhs: Self , _ rhs: Self) -> Self {
    Self.plus(lhs, rhs)
  }
  public static func + (_ lhs: Self, _ rhs: Element) -> Self {
    Self.plus(rhs, lhs)
  }
  public static func + (_ lhs: Element, _ rhs: Self) -> Self {
    Self.plus(lhs, rhs)
  }
}
