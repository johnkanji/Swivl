//  MatrixProtocol.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

public protocol MatrixProtocol: Collection, Equatable where Element: Numeric {
  typealias Scalar = Element

  var rows: Int { get }
  var cols: Int { get }
  var shape: RowCol { get }


  //  MARK: Matrix Properties

  var isSymmetric: Bool { get }

  var isLowerTringular: Bool { get }

  var isUpperTriangular: Bool { get }

  var isDiagonal: Bool { get }

  
  var trace: Scalar { get }

  var norm: Scalar { get }


  // MARK: Initializers

  init(_ rows: [[Scalar]])
  init(columns: [[Scalar]])
  init(flat: [Scalar], shape: RowCol)


  //  MARK: Subscripts

  subscript(_ row: Index, _ column: Index) -> Scalar { get set }

  func rowColumnToFlatIndex(_ i: RowCol) -> Index
  func flatIndexToRowColumn(_ i: Index) -> RowCol


  //  MARK: Manipulation

  /// Copy and transpose
  var T: Self { get }

  static postfix func †(_ a: Self) -> Self

  func diag<V>() -> V where V: VectorProtocol, V.T == Scalar

  func tri(_ triangle: TriangularType, diagonal: Int) -> Self


  //  MARK: Unary Operators

  static func negate(_ lhs: Self) -> Self

  func abs() -> Self

  func max() -> (Scalar, RowCol)?

  func min() -> (Scalar, RowCol)?

  func sum() -> Scalar

  func square() -> Self


  //  MARK: Arithmetic

  static func add(_ lhs: Self, _ rhs: Self) -> Self
  static func add(_ lhs: Self, _ rhs: Element) -> Self

  static func subtract(_ lhs: Self, _ rhs: Self) -> Self
  static func subtract(_ lhs: Self, _ rhs: Element) -> Self

  static func multiplyElements(_ lhs: Self, _ rhs: Self) -> Self
  static func multiplyElements(_ lhs: Self, _ rhs: Element) -> Self

  static func divideElements(_ lhs: Self, _ rhs: Self) -> Self
  static func divideElements(_ lhs: Self, _ rhs: Element) -> Self


  static func multiplyMatrix(_ lhs: Self, _ rhs: Self) -> Self


  //  MARK: Matrix Creation

  static func zeros(_ rows: Int, _ cols: Int) -> Self

  static func ones(_ rows: Int, _ cols: Int) -> Self

  static func rand(_ rows: Int, _ cols: Int) -> Self

  static func randn(_ rows: Int, _ cols: Int) -> Self

  static func eye(_ n: Int) -> Self
  
}


//  MARK: Default Implementations

extension MatrixProtocol {

//  MARK: Operators

  static func + (_ lhs: Self, _ rhs: Self) -> Self {
    Self.add(lhs, rhs)
  }
  static func + (_ lhs: Self, _ rhs: Element) -> Self {
    Self.add(lhs, rhs)
  }
  static func + (_ lhs: Element, _ rhs: Self) -> Self {
    Self.add(rhs, lhs)
  }

  static func - (_ lhs: Self, _ rhs: Self) -> Self {
    Self.subtract(lhs, rhs)
  }
  static func - (_ lhs: Self, _ rhs: Element) -> Self {
    Self.subtract(lhs, rhs)
  }

  static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiplyElements(lhs, rhs)
  }
  static func .* (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiplyElements(lhs, rhs)
  }
  static func .* (_ lhs: Element, _ rhs: Self) -> Self {
    Self.multiplyElements(rhs, lhs)
  }
  static func * (_ lhs: Self, _ rhs: Element) -> Self {
    Self.multiplyElements(lhs, rhs)
  }
  static func * (_ lhs: Element, _ rhs: Self) -> Self {
    Self.multiplyElements(rhs, lhs)

  }

  static func ./ (_ lhs: Self, _ rhs: Self) -> Self {
    Self.divideElements(lhs, rhs)
  }
  static func ./ (_ lhs: Self, _ rhs: Element) -> Self {
    Self.divideElements(lhs, rhs)
  }
  static func ./ (_ lhs: Element, _ rhs: Self) -> Self {
    Self.divideElements(rhs, lhs)
  }
  static func / (_ lhs: Self, _ rhs: Element) -> Self {
    Self.divideElements(lhs, rhs)
  }
  static func / (_ lhs: Element, _ rhs: Self) -> Self {
    Self.divideElements(rhs, lhs)
  }

  static func * (_ lhs: Self, _ rhs: Self) -> Self {
    Self.multiplyMatrix(lhs, rhs)
  }

}
