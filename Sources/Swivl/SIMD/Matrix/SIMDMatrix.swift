//  SIMDMatrix.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

public protocol SIMDMatrix: MatrixProtocol where Scalar: SwivlNumeric {
  associatedtype RowVector: SIMD where RowVector.Scalar == Scalar
  associatedtype ColumnVector: SIMD where ColumnVector.Scalar == Scalar

  static var _rows: Int { get }
  static var _cols: Int { get }

  init(rows: [RowVector])
  init(_ scalar: Scalar)

  var transpose: Self { get }

  subscript(_ position: Int) -> Scalar { get set }
  subscript(_ row: Int, _ column: Int) -> Scalar { get set }

  static prefix func - (_ a: Self) -> Self
}

extension SIMDMatrix where Scalar: SwivlFloatingPoint {

  public var rows: Int { Self._rows }
  public var cols: Int { Self._cols }
  public var shape: RowCol { (rows, cols) }



//  MARK: Matrix Properties

  public var isSymmetric: Bool {
    self == self†
  }

  //  TODO: STUB
  public var isLowerTringular: Bool {
    false
  }

  //  TODO: STUB
  public var isUpperTriangular: Bool {
    false
  }

  public var isDiagonal: Bool {
    false
//    self == self.diag().diag()
  }

  public var trace: Scalar {
    0
//    self.diag().square().sum()
  }

  public var norm: Scalar {
    self.square().sum()
  }


//  MARK: Initializers

  init(simdRows: [RowVector]) {
    self.init(rows: simdRows)
  }

  public init(_ rows: [[Scalar]]) {
    self.init(rows.reduce([], +))
  }

  public init(columns: [[Scalar]]) {
    self.init(LinAlg.transpose(Mat<Scalar>(columns.reduce([], +), (Self._cols, Self._rows))))
  }

  public init(_ s: [Scalar]) {
    var vs: [RowVector] = []
    (0..<Self._rows).forEach { r in
      vs.append(RowVector(s[r..<r+Self._cols]))
    }
    self.init(simdRows: vs)
  }

  public init(flat: [Scalar], shape: RowCol) {
    self.init(flat)
  }

  init(_ a: Mat<Scalar>) {
    self.init(a.flat)
  }


//  MARK: Subscripts

  public var startIndex: Int { 0 }
  public var endIndex: Int { self.rows*self.cols }

  public subscript(position: Int) -> Scalar {
    _read {
      let rc = flatIndexToRowColumn(position)
      yield self[rc.r, rc.c]
    }
    set {
      let rc = flatIndexToRowColumn(position)
      self[rc.r, rc.c] = newValue
    }
  }

  public func rowColumnToFlatIndex(_ i: RowCol) -> Int {
    i.r * cols + i.c
  }

  public func flatIndexToRowColumn(_ i: Int) -> RowCol {
    let d = Double(i)
    return (Int(floor(d/Double(shape.c))), Int(d.truncatingRemainder(dividingBy: Double(shape.c))))
  }

  public func index(after i: Int) -> Int {
    precondition(i >= startIndex && i < endIndex)
    return i + 1
  }


//  MARK: Manipulation

  public var T: Self {
    self.transpose
  }

  public static postfix func † (a: Self) -> Self {
    a.T
  }

  public func diag<V>() -> V where V : VectorProtocol, V.Scalar == Scalar {
    V((0..<Swift.min(rows, cols)).map { i in self[i,i] })
  }

  public func tri(_ triangle: TriangularType, diagonal: Int) -> Self {
    Self([])
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    lhs
  }

  public func abs() -> Self {
    Self(self.array().map { Swift.abs($0) })
  }

  public func max() -> (Scalar, RowCol)? {
    let v = self.array()
    guard let m = self.array().max() else { return nil }
    return (m, flatIndexToRowColumn(v.firstIndex(of: m)!))
  }

  public func min() -> (Scalar, RowCol)? {
    let v = self.array()
    guard let m = self.array().min() else { return nil }
    return (m, flatIndexToRowColumn(v.firstIndex(of: m)!))
  }

  public func sum() -> Scalar {
    self.array().sum()
  }

  public func square() -> Self {
    self.*self
  }


//  MARK: Arithmetic

  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return lhs + rhs
  }

  public static func add(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs + Self([Scalar](repeating: rhs, count: lhs.rows*lhs.cols))
  }

  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return lhs - lhs
  }

  public static func subtract(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs - Self([Scalar](repeating: rhs, count: lhs.rows*lhs.cols))
  }

  public static func multiplyElements(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return lhs * rhs
  }

  public static func multiplyElements(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs * Self([Scalar](repeating: rhs, count: lhs.rows*lhs.cols))
  }

  public static func multiplyMatrix(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.cols == rhs.rows)
    return lhs * lhs
  }

  public static func .* (lhs: Self, rhs: Self) -> Self {
    lhs * rhs
  }


//  MARK: Vector Creation

  public static func zeros(_ rows: Int, _ cols: Int) -> Self {
    Self([Scalar](repeating: 0, count: rows*cols))
  }

  public static func ones(_ rows: Int, _ cols: Int) -> Self {
    Self([Scalar](repeating: 1, count: rows*cols))
  }

  public static func rand(_ rows: Int, _ cols: Int) -> Self {
    //  TODO: Generator
    Self((0..<(rows*cols)).map { _ in Scalar.random(in: 0...1) })
  }

  public static func randn(_ rows: Int, _ cols: Int) -> Self {
    //  TODO: Generator
    Self((0..<(rows*cols)).map { _ in Scalar.random(in: 0...1) })
  }

  public static func eye(_ n: Int) -> Self {
    Self(1)
  }


//  MARK: Conversions

  public func array() -> [Scalar] {
    var vs: [[Scalar]] = []
    for i in 0..<rows {
      var v: [Scalar] = []
      for j in 0..<cols {
        v.append(self[i,j])
      }
      vs.append(v)
    }
    return vs.reduce([], +)
  }

}
