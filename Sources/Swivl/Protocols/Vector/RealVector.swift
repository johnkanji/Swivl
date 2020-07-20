//  RealVector.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

public protocol RealVector: VectorProtocol {

//  MARK: Vector Properties

  var length: Scalar { get }


//  MARK: Unary Operators

  func mean() -> Scalar


//  MARK: Arithmetic

  /// Perform vector right division.
  ///
  /// Alternatively, `divide(lhs, rhs)` can be executed with `a ./ b`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: result of elementwise division of a by b
  static func divide(_ lhs: Self, _ rhs: Self) -> Self


  //  MARK: Geometric Operations

  static func normalize(_ v: Self) -> Self

  static func project(_ a: Self, onto b: Self) -> Self

  static func dist(_ a: Self, _ b: Self) -> Scalar


//  MARK: Vector Creation

  static func linear(_ start: Scalar, _ stop: Scalar, _ count: Int) -> Self

  static func rand(_ count: Int) -> Self

  static func randn(_ count: Int) -> Self
  
}

extension RealVector {

  public var length: Scalar { self._length() }
  public var norm: Scalar { self._length() }


//  MARK: Geometric Operations

  public func dist(_ v: Self) -> Scalar { Self.dist(self, v) }

  public func project(onto v: Self) -> Self { Self.project(self, onto: v) }

  public func normalized() -> Self { Self.normalize(self) }


  /// Perform vector right division.
  ///
  /// Alternatively, `a ./ b` can be executed with `divide(lhs, rhs)`.
  ///
  /// - Parameters
  ///     - lhs: left vector
  ///     - rhs: right vector
  /// - Returns: result of elementwise division of a by b
  static func ./ (_ lhs: Self, _ rhs: Self) -> Self {
    Self.divide(lhs, rhs)
  }

}
