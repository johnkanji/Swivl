//  SparseMatrix.swift
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

public struct SparseMatrix<Scalar>: MatrixProtocol where Scalar: AccelerateFloatingPoint {
  public typealias Element = Scalar
  public typealias Index = Int

  var _rows: Int
  var _cols: Int
  var _layout = MatrixLayout.columnMajor

  var _rowIndices: [Int32] = []
  var _columnStarts: [Int] = []
  var _values: [Scalar]
  var _blockSize: UInt8 = 1

  public var rows: Int { _rows }
  public var cols: Int { _cols }
  public var shape: RowCol { RowCol(rows, cols) }


//  MARK: Matrix Properties

  public var isSymmetric: Bool {
    false
  }

  public var isLowerTringular: Bool {
    false
  }

  public var isUpperTriangular: Bool {
    false
  }

  public var isDiagonal: Bool {
    false
  }

  public var trace: Scalar {
    0
  }

  public var norm: Scalar {
    0
  }


//  MARK: Initializers

  public init() {
    _rows = 0
    _cols = 0
    _rowIndices = []
    _columnStarts = []
    _values = []
  }

  public init(
    rowIndices: [Int32], columnStarts: [Int], _ values: [Scalar],
    _ rows: Int? = nil, _ cols: Int? = nil
  ) {
    precondition(rowIndices.count == values.count)
    self._rows = rows ?? Int(rowIndices.max()!)
    self._cols = cols ?? columnStarts.count
    self._values = values
    self._rowIndices = rowIndices
    self._columnStarts = columnStarts
  }

//  TODO: Storage should be sorted for faster indexing
  public init(
    _ rowIndices: [Int], _ colIndices: [Int], _ values: [Scalar],
    _ rows: Int? = nil, _ cols: Int? = nil
  ) {
    precondition(rowIndices.count == colIndices.count && rowIndices.count == values.count)
    self._rows = rows ?? Int(rowIndices.max()! + 1)
    self._cols = cols ?? Int(colIndices.max()! + 1)
    self._values = values
    let comp: (RowCol, RowCol) -> Bool = { a, b in (a.c < b.c) || (a.c <= b.c && a.r <= b.r) }
    self._rowIndices = zip(rowIndices, colIndices).sorted(by: comp).map { Int32($0.0) }
    self._columnStarts = colIndices.reduce(into: [Int](repeating: 0, count: _cols)) { acc, c in acc[c] += 1 }.cumsum()
  }

  public init(_ m: Matrix<Scalar>) {
    let rcs = m._flat.enumerated().filter { $0.1 != 0 }.map { m.flatIndexToRowColumn($0.0) }
    self.init(rcs.map { $0.r }, rcs.map { $0.c }, m._flat.filter { $0 != 0 }, m.rows, m.cols)
  }

  public init(_ rows: [[Scalar]]) {
    self.init()
  }

  public init(columns: [[Scalar]]) {
    self.init()
  }

  public init(flat: [Scalar], shape: RowCol) {
    self.init()
  }


//  MARK: Subscripts

  public subscript(position: Int) -> Scalar {
    _read { yield 0 }
  }

  public subscript(row: Index, column: Index) -> Scalar {
    get { 0 }
    set {  }
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

  public func index(after i: Int) -> Int {
    precondition(i >= startIndex && i < endIndex)
    return i + 1
  }

  public var startIndex: Int = 0
  public var endIndex: Int { rows*cols }


//  MARK: Manipulation

  public var T: Self {
    Self()
  }

  public static postfix func † (a: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    a.T
  }

  public func diag<V>() -> V where V : VectorProtocol, Self.Scalar == V.T {
    V()
  }

  public func tri(_ triangle: TriangularType, diagonal: Int) -> SparseMatrix<Scalar> {
    Self()
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    lhs
  }

  public func abs() -> SparseMatrix<Scalar> {
    self
  }

  public func max() -> (Scalar, RowCol)? {
    nil
  }

  public func min() -> (Scalar, RowCol)? {
    nil
  }

  public func sum() -> Scalar {
    0
  }

  public func square() -> SparseMatrix<Scalar> {
    self
  }


//  MARK: Arithmetic

  public static func add(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func add(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func subtract(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func subtract(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func multiplyElements(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func multiplyElements(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func divideElements(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func divideElements(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func multiplyMatrix(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self()
  }


//  MARK: Matrix Creation

  public static func zeros(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func ones(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func rand(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func randn(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func eye(_ n: Int) -> SparseMatrix<Scalar> {
    Self(rowIndices: Array(0..<Int32(n)), columnStarts: Array(0...n), [Scalar](repeating: 1, count: n))
  }

}
