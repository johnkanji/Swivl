//  RealVector.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

public protocol RealVector: VectorProtocol {

//  MARK: Vector Properties

  var length: T { get }


//  MARK: Unary Operators

  func mean() -> T


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


//  MARK: Geometry

  static func dist(_ a: Self, _ b: Self) -> T


//  MARK: Vector Creation

  static func linear(_ start: T, _ stop: T, _ count: Int) -> Self

  static func rand(_ count: Int) -> Self

  static func randn(_ count: Int) -> Self
  
}

extension RealVector {

  var norm: T { self.length }


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
