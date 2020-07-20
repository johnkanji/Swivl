//  Matrix.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

public struct Matrix<Scalar>: MatrixProtocol where Scalar: SwivlNumeric {
  public typealias Element = Scalar
  public typealias Index = Array<Scalar>.Index
  
  public var _flat: [Scalar]
  var _rows: Int
  var _cols: Int
  var _layout: MatrixLayout = .defaultLayout
  
  public var rows: Int { _rows }
  public var cols: Int { _cols }
  public var flat: [Scalar] { _flat }
  public var shape: RowCol { RowCol(_rows, _cols) }
  public var layout: MatrixLayout { _layout }
  
  public var count: Int { flat.count }
  public var startIndex: Index { flat.startIndex }
  public var endIndex: Index { flat.endIndex }

  var _mat: Mat<Scalar> { Mat<Scalar>(_flat, shape) }


//  MARK: Matrix Properties

  public var isSquare: Bool {
    rows == cols
  }

  public var isSymmetric: Bool {
    self == self†
  }

  public var isLowerTringular: Bool {
    self == self.tri(.lower)
  }

  public var isUpperTriangular: Bool {
    self == self.tri(.upper)
  }

  public var isDiagonal: Bool {
    let diagonal: Vector<Scalar> = self.diag()
    return self == diagonal.diag()
  }

  var _definite: Bool? = nil

  public var trace: Scalar {
    LinAlg.trace(_mat)
  }

  public var norm: Scalar {
    _flat.map { $0*$0 }.sum()
  }
  
  
// MARK: Initializers
  
  public init(rows: [[Scalar]]) {
    precondition(
      !rows.isEmpty && !rows.first!.isEmpty &&
      rows.allSatisfy { $0.count == rows.first!.count })
    
    self._rows = rows.count
    self._cols = rows.first!.count
    self._flat = rows.reduce([], +)
  }
  public init(_ rows: [[Scalar]]) { self.init(rows: rows) }
  public init(columns: [[Scalar]]) {
    precondition(
      !columns.isEmpty && !columns.first!.isEmpty &&
      columns.allSatisfy { $0.count == columns.first!.count })
    
    self._cols = columns.count
    self._rows = columns.first!.count
    self._flat = columns.reduce([], +)
  }
  public init(flat: [Scalar], shape: RowCol) {
    self._flat = flat
    (self._rows, self._cols) = shape
  }
  public init(flat: [Scalar], shape: RowCol, layout: MatrixLayout = .defaultLayout) {
    self._flat = flat
    (self._rows, self._cols) = shape
    self._layout = layout
  }

  init(_ a: Mat<Scalar>, layout: MatrixLayout = .defaultLayout) {
    _flat = a.flat
    (_rows, _cols) = a.shape
  }
  
  
//  MARK: Subscripts
//  TODO: Subscript assignments
  
  public subscript(position: Array<Scalar>.Index) -> Scalar {
    _read {
      yield flat[position]
    }
  }
  
  public subscript(_ row: Index, _ column: Index) -> Scalar {
    get { flat[rowColumnToFlatIndex(RowCol(row, column))] }
    set { _flat[rowColumnToFlatIndex(RowCol(row, column))] = newValue }
  }
  
  public func rowColumnToFlatIndex(_ i: RowCol) -> Index {
    if _layout == .rowMajor {
      return i.r * cols + i.c
    } else {
      return i.c * rows + i.r
    }
  }
  public func flatIndexToRowColumn(_ i: Index) -> RowCol {
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
  
  
//  MARK: Manipulation
  
  /// Copy and transpose
  public var T: Self {
    Self(LinAlg.transpose(_mat))
  }
  
  public static postfix func †(_ a: Self) -> Self {
    a.T
  }
  
  /// Transpose in place
  public mutating func transpose() {
    (_flat, (_rows, _cols)) = LinAlg.transpose(_mat)
  }

  public static func hcat(_ matrices: Self...) -> Self {
    return Self.init(LinAlg.hcat(matrices.map(\._mat)))
  }

  public static func vcat(_ matrices: Self...) -> Self {
    return Self.init(LinAlg.vcat(matrices.map(\._mat)))
  }

  public static func || (_ lhs: Self, _ rhs: Self) -> Self {
    vcat(lhs, rhs)
  }

  public func diag<V>() -> V where V: VectorProtocol, V.Scalar == Scalar {
    V(LinAlg.diag(_mat))
  }
  public func diag() -> Vector<Scalar> {
    Vector(LinAlg.diag(_mat))
  }

  public func tri(_ triangle: TriangularType, diagonal: Int = 0) -> Self {
    Self(LinAlg.triangle(_mat, triangle, diagonal: diagonal))
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: Self) -> Self {
    Self(flat: lhs._flat.map { x in -x }, shape: lhs.shape)
  }

  public func abs() -> Self {
    Self(flat: LinAlg.abs(_flat), shape: shape)
  }

  public func max() -> (Scalar, RowCol)? {
    guard let m = _flat.max() else { return nil }
    return (m, flatIndexToRowColumn(_flat.firstIndex(of: m)!))
  }
  public func min() -> (Scalar, RowCol)? {
    guard let m = _flat.min() else { return nil }
    return (m, flatIndexToRowColumn(_flat.firstIndex(of: m)!))
  }

  public func sum() -> Scalar {
    _flat.sum()
  }

  public func mean<R>() -> R where R: SwivlFloatingPoint {
    self.to(type: R.self).mean()
  }

  public func square() -> Self {
    Self(flat: _flat.map { $0*$0 }, shape: shape)
  }
  
  
//  MARK: Arithmetic
  
  public static func add(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: LinAlg.add(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func add(_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: LinAlg.addScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  
  public static func subtract(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: LinAlg.subtract(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func subtract(_ lhs: Self, _ rhs: Element) -> Self {
    return Self(flat: LinAlg.subtractScalar(lhs._flat, rhs), shape: lhs.shape)
  }
  
  public static func multiplyElements(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: zip(lhs._flat, rhs._flat).map { $0*$1 }, shape: lhs.shape)
  }
  public static func multiplyElements(_ lhs: Self, _ rhs: Scalar) -> Self {
    return Self(flat: lhs._flat.map { $0*rhs }, shape: lhs.shape)
  }
  
  public static func divideElements(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return Self(flat: LinAlg.divideElementwise(lhs._flat, rhs._flat), shape: lhs.shape)
  }
  public static func divideElements(_ lhs: Self, _ rhs: Scalar) -> Self {
    return Self(flat: LinAlg.divideScalar(lhs._flat, rhs), shape: lhs.shape)
  }

  
  public static func multiplyMatrix(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.cols == rhs.rows, "Matrix dimensions do not agree")
    let (m, p) = lhs.shape
    let n = rhs.cols
    var out = zeros(m, n)
    for r in 0..<m {
      for c in 0..<n {
        var acc: Scalar = 0
        for i in 0..<p {
          acc += lhs[r,i]*rhs[i,c]
        }
        out[r,c] = acc
      }
    }
    return out
  }
  
  
//  MARK: Matrix Creation

  public static func zeros(_ rows: Int, _ cols: Int) -> Self {
    return Self(flat: [Scalar](repeating: 0, count: rows*cols), shape: RowCol(rows, cols))
  }
  
  public static func ones(_ rows: Int, _ cols: Int) -> Self {
    return Self(flat: [Scalar](repeating: 1, count: rows*cols), shape: RowCol(rows, cols))
  }

//  TODO: STUB
  public static func rand(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: [], shape: (rows, cols))
  }

//  TODO: STUB
  public static func randn(_ rows: Int, _ cols: Int) -> Self {
    Self(flat: [], shape: (rows, cols))
  }

  public static func eye(_ n: Int) -> Self {
    return Self(LinAlg.eye(n))
  }

  
  
//  MARK: Conversion
  
  public func vector<V>() -> V where V: VectorProtocol, V.Element == Scalar {
    precondition(rows == 1 || cols == 1)
    return V(_flat, shape: shape)
  }

  public func to<U>(type: U.Type) -> Matrix<U> where U: SwivlNumeric {
    Matrix<U>(flat: LinAlg.toType(_flat, type), shape: shape)
  }
  
}
