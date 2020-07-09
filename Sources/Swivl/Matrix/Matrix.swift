//  Matrix.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate
import BLAS

public struct Matrix<T>: MatrixProtocol where T: AccelerateNumeric {
  public typealias Index = Array<T>.Index
  public typealias Element = T
  
  var _flat: [T]
  var _rows: Int
  var _cols: Int
  var _layout: MatrixLayout = .defaultLayout
  
  public var rows: Int { _rows }
  public var cols: Int { _cols }
  public var flat: [T] { _flat }
  public var shape: RowCol { RowCol(_rows, _cols) }
  public var layout: MatrixLayout { _layout }
  
  public var count: Int { flat.count }
  public var startIndex: Index { flat.startIndex }
  public var endIndex: Index { flat.endIndex }
  
  
// MARK: Initializers
  
  public init(rows: [[Element]]) {
    precondition(
      !rows.isEmpty && !rows.first!.isEmpty &&
      rows.allSatisfy { $0.count == rows.first!.count })
    
    self._rows = rows.count
    self._cols = rows.first!.count
    self._flat = rows.reduce([], +)
  }
  public init(_ rows: [[Element]]) { self.init(rows: rows) }
  public init(columns: [[Element]]) {
    precondition(
      !columns.isEmpty && !columns.first!.isEmpty &&
      columns.allSatisfy { $0.count == columns.first!.count })
    
    self._cols = columns.count
    self._rows = columns.first!.count
    self._flat = columns.reduce([], +)
  }
  public init(flat: [Element], shape: RowCol) {
    self._flat = flat
    (self._rows, self._cols) = shape
  }
  public init(flat: [Element], shape: RowCol, layout: MatrixLayout = .defaultLayout) {
    self._flat = flat
    (self._rows, self._cols) = shape
    self._layout = layout
  }
  
  
//  MARK: Subscripts
//  TODO: Subscript assignments
  
  public subscript(position: Array<T>.Index) -> T {
    _read {
      yield flat[position]
    }
  }
  
  public subscript(_ row: Index, _ column: Index) -> T {
    get { flat[rowColumnToFlatIndex(RowCol(row, column))] }
    set { _flat[rowColumnToFlatIndex(RowCol(row, column))] = newValue }
  }
  
  func rowColumnToFlatIndex(_ i: RowCol) -> Index {
    if _layout == .rowMajor {
      return i.r * cols + i.c
    } else {
      return i.c * rows + i.r
    }
  }
  func flatIndexToRowColumn(_ i: Index) -> RowCol {
    let d = Double(i)
    if _layout == .rowMajor {
      return (Int(floor(d/Double(shape.c))), Int(d.truncatingRemainder(dividingBy: Double(shape.c))))
    } else {
      return (Int(floor(d/Double(shape.r))), Int(d.truncatingRemainder(dividingBy: Double(shape.r))))
    }
  }
  
  public func index(after i: Index) -> Index {
    flat.index(after: i)
  }
  
  
//  MARK: Transposition
  
  /// Copy and transpose
  public var T: Self {
    Self(flat: BLAS.transpose(flat, shape), shape: (shape.c, shape.r))
  }
  
  public static postfix func †(_ a: Self) -> Self {
    a.T
  }
  
  /// Transpose in place
  public mutating func transpose() {
    _flat = BLAS.transpose(flat, shape)
  }
  
  
//  MARK: Unary Operators
  
  public static func negate(_ lhs: Self) -> Self {
    Self(flat: lhs._flat.map { x in -x }, shape: lhs.shape)
  }
  public static func negate(_ lhs: Self) -> Self where T: AccelerateFloatingPoint {
    Self(flat: BLAS.negate(lhs._flat), shape: lhs.shape)
  }
  
  public func abs() -> Self {
    Self(flat: BLAS.abs(_flat), shape: shape)
  }
  
  public func max() -> (T, RowCol)? {
    guard let m = _flat.max() else { return nil }
    return (m, flatIndexToRowColumn(_flat.firstIndex(of: m)!))
  }
  public func min() -> (T, RowCol)? {
    guard let m = _flat.min() else { return nil }
    return (m, flatIndexToRowColumn(_flat.firstIndex(of: m)!))
  }
  
  public func sum() -> T {
    _flat.sum()
  }
  
  public func mean() -> Double where T: BinaryInteger {
    Double(_flat.sum()) / Double(_flat.count)
  }
  public func mean() -> T where T: AccelerateFloatingPoint {
    BLAS.mean(_flat)
  }
  
  public func square() -> Self where T: BinaryInteger {
    Self(flat: _flat.map { $0*$0 }, shape: shape)
  }
  public func square() -> Self where T: AccelerateFloatingPoint {
    Self(flat: BLAS.square(_flat), shape: shape)
  }
  
  
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
  
  //  TODO: STUB
  public var det: T {
    0
  }
  
  //  TODO: STUB
  public var trace: T {
    0
  }
  
  //  TODO: STUB
  public var cond: T {
    0
  }
  
  
//  MARK: Binary Element-wise Operators
  
  public static func + (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: BLAS.add(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func + (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.addScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func + (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: BLAS.addScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  
  public static func - (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: BLAS.subtract(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func - (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.subtractScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  
  public static func .* (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: zip(lhs._flat, rhs._flat).map { $0*$1 }, shape: lhs.shape)
  }
  public static func .* (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: lhs._flat.map { $0*rhs }, shape: lhs.shape)
  }
  public static func .* (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: rhs._flat.map { $0*lhs }, shape: rhs.shape)
  }
  public static func * (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: lhs._flat.map { $0*rhs }, shape: lhs.shape)
  }
  public static func * (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: rhs._flat.map { $0*lhs }, shape: rhs.shape)
  }
  
  public static func .* (_ lhs: Self, _ rhs: Self) -> Self
  where T: AccelerateFloatingPoint {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: BLAS.multiplyElementwise(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func .* (_ lhs: Self, _ rhs: Element) -> Self
  where T: AccelerateFloatingPoint {
    return Self(flat: BLAS.multiplyScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func .* (_ lhs: Element, _ rhs: Self) -> Self
  where T: AccelerateFloatingPoint {
    return Self(flat: BLAS.multiplyScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  public static func * (_ lhs: Self, _ rhs: Element) -> Self
  where T: AccelerateFloatingPoint {
    return Self(flat: BLAS.multiplyScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func * (_ lhs: Element, _ rhs: Self) -> Self
  where T: AccelerateFloatingPoint {
    return Self(flat: BLAS.multiplyScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  
  
  public static func ./ (_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: BLAS.divideElementwise(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func ./ (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.divideScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func ./ (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: BLAS.divideScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  public static func / (_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: BLAS.divideScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  public static func / (_ lhs: Element, _ rhs: Self) -> Self {
    return Self(flat: BLAS.divideScalar(rhs._flat, lhs), shape: rhs.shape)
  }
  
  
//  MARK: Matrix-Matrix Arithmetic
  
  public static func mmul(_ lhs: Self, _ rhs: Self) -> Self where T: BinaryInteger {
    precondition(lhs.cols == rhs.rows, "Matrix dimensions do not agree")
    let (m, p) = lhs.shape
    let n = rhs.cols
    var out = zeros(m, n)
    for r in 0..<m {
      for c in 0..<n {
        var acc: T = 0
        for i in 0..<p {
          acc += lhs[r,i]*rhs[i,c]
        }
        out[r,c] = acc
      }
    }
    return out
  }
  
  public static func * (_ lhs: Self, _ rhs: Self) -> Self where T: BinaryInteger {
    Self.mmul(lhs, rhs)
  }
  public static func * (_ lhs: Self, _ rhs: Self) -> Self where T: AccelerateFloatingPoint {
    let (c, shapeC) = BLAS.multiplyMatrix(lhs._flat, lhs.shape, rhs._flat, rhs.shape)
    return Self(flat: c, shape: shapeC)
  }
  
  
//  MARK: Matrix Generation

  public static func zeros(_ rows: Int, _ cols: Int) -> Self {
    return Self(flat: [T](repeating: 0, count: rows*cols), shape: RowCol(rows, cols))
  }
  
  public static func ones(_ rows: Int, _ cols: Int) -> Self {
    return Self(flat: [T](repeating: 1, count: rows*cols), shape: RowCol(rows, cols))
  }
  
  public static func rand(_ rows: Int, _ cols: Int) -> Self where T: AccelerateFloatingPoint {
    Self(flat: BLAS.rand(rows*cols), shape: (rows, cols))
  }
  
  public static func randn(_ rows: Int, _ cols: Int) -> Self where T: AccelerateFloatingPoint {
    Self(flat: BLAS.randn(rows*cols), shape: (rows, cols))
  }
  
  //  TODO: STUB
  public static func eye(_ n: Int) -> Self {
    return Self()
  }
  
  
  
//  MARK: Decompositions
  
  public func LU(_ output: BLAS.LUOutput = .LU) -> (L: Self, U: Self, P: Self?, Q: Self?)
  where T: AccelerateFloatingPoint {
    switch output {
    case .LU:
      let (L, U, _, _) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shape), U: Self(flat: U, shape: shape), nil, nil)
    case .LUP:
      let (L, U, P, _) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shape), U: Self(flat: U, shape: shape), P: Self(flat: P!, shape: shape), nil)
    case .LUPQ:
      let (L, U, P, Q) = BLAS.LU(_flat, shape, output: output)
      return (L: Self(flat: L, shape: shape), U: Self(flat: U, shape: shape),
              P: Self(flat: P!, shape: shape), Q: Self(flat: Q!, shape: shape))
    }
  }
  
  public func eig(vectors: BLAS.EigenvectorOutput = .none) -> (values: Vector<T>, leftVectors: Self?, rightVectors: Self?)
  where T: AccelerateFloatingPoint {
    let left = vectors == .left || vectors == .both
    let right = vectors == .right || vectors == .both

    let (V, DL, DR) = BLAS.eig(_flat, shape, vectors: vectors)
    return (Vector(V), left ? Self(flat: DL!, shape: shape) : nil, right ? Self(flat: DR!, shape: shape) : nil)
  }
  
  
//  MARK: Conversion
  
  public func vector() -> Vector<T> {
    precondition(rows == 1 || cols == 1)
    return Vector(_flat, shape: shape)
  }
  
}


public enum MatrixLayout {
  case rowMajor
  case columnMajor
  case diagonal
  case block
  
  public static var defaultLayout = rowMajor
}
