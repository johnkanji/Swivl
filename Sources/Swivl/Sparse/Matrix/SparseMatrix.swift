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
import LinearAlgebra

public struct SparseMatrix<Scalar>: MatrixProtocol where Scalar: SwivlNumeric {
  public typealias Element = Scalar
  public typealias Index = Int

  var _rows: Int
  var _cols: Int
  var _layout = MatrixLayout.columnMajor

  public var _rowIndices: [Int32] = []
  public var _columnStarts: [Int] = []
  public var _values: [Scalar]
  var _blockSize: UInt8 = 1

  public var rows: Int { _rows }
  public var cols: Int { _cols }
  public var shape: RowCol { RowCol(rows, cols) }
  public var nonZeros: Int { _values.count }

  public var _spmat: SpMat<Scalar> { SpMat<Scalar>(ri: _rowIndices, cs: _columnStarts, v: _values, shape: shape) }


//  MARK: Matrix Properties

  public var isSymmetric: Bool {
    self == self†
  }

  public var isLowerTringular: Bool {
    false
  }

  public var isUpperTriangular: Bool {
    false
  }

  public var isDiagonal: Bool {
    let diagonal: Vector<Scalar> = self.diag()
    return self == diagonal.diag()
  }

  public var trace: Scalar {
    LinAlg.diag(_spmat).sum()
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
    self._rows = rows ?? Int(rowIndices.max()! + 1)
    self._cols = cols ?? (columnStarts.count - 1)
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
    let shape = rows != nil && cols != nil ? RowCol(rows!, cols!) : nil
    self.init(LinAlg.tripletToCSC(rowIndices, colIndices, values, shape: shape))
  }

  public init(_ m: Matrix<Scalar>) {
    self.init(LinAlg.denseToCSC(m._mat))
  }

  public init(_ rows: [[Scalar]]) {
    precondition(
      !rows.isEmpty && !rows.first!.isEmpty &&
      rows.allSatisfy { $0.count == rows.first!.count })
    let shape = (rows.count, rows[0].count)
    self.init(flat: rows.chained(), shape: shape)
  }

  public init(columns: [[Scalar]]) {
    precondition(
      !columns.isEmpty && !columns.first!.isEmpty &&
      columns.allSatisfy { $0.count == columns.first!.count })
    let shape = (columns.count, columns[0].count)
    let mat = LinAlg.transpose((columns.chained(), shape))
    self.init(flat: mat.flat, shape: mat.shape)
  }

  public init(flat: [Scalar], shape: RowCol) {
    self.init(LinAlg.denseToCSC((flat, shape)))
  }

  public init(_ a: SpMat<Scalar>) {
    self._rowIndices = a.ri
    self._columnStarts = a.cs
    self._values = a.v
    self._rows = a.shape.r
    self._cols = a.shape.c
  }


//  MARK: Subscripts

  public subscript(position: Int) -> Scalar {
    _read { yield _values[position] }
  }

  public subscript(row: Index, column: Index) -> Scalar {
    get {
      guard let vi = LinAlg.rowColToValueIndex(_spmat, (row, column)) else { return 0 }
      return _values[vi]
    }
    set { LinAlg.insert(&_rowIndices, &_columnStarts, &_values, shape, (row, column), newValue) }
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
  func valueIndexToRowColumn(_ vi: Index) -> RowCol {
    LinAlg.valueIndexToRowCol(_spmat, vi)
  }

  public func index(after i: Int) -> Int {
    precondition(i >= startIndex && i < endIndex)
    return i + 1
  }

  public var startIndex: Int = 0
  public var endIndex: Int { rows*cols }


//  MARK: Manipulation

  public var T: Self {
    Self(LinAlg.transpose(_spmat))
  }

  public static postfix func † (a: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    a.T
  }

  public mutating func transpose() {
    let spmat = LinAlg.transpose(_spmat)
    self._rowIndices = spmat.ri
    self._columnStarts = spmat.cs
    self._values = spmat.v
    self._rows = spmat.shape.r
    self._cols = spmat.shape.c
  }

  public static func hcat(_ matrices: Self...) -> Self {
    return Self.init(LinAlg.hcat(matrices.map(\._spmat)))
  }

  public static func vcat(_ matrices: Self...) -> Self {
    return Self.init(LinAlg.vcat(matrices.map(\._spmat)))
  }

  public static func & (_ lhs: Self, _ rhs: Self) -> Self {
    vcat(lhs, rhs)
  }

  public func diag<V>() -> V where V : VectorProtocol, Self.Scalar == V.Scalar {
    V(LinAlg.diag(_spmat))
  }
  public func diag() -> Vector<Scalar> {
    Vector(LinAlg.diag(_spmat))
  }

  public func tri(_ triangle: TriangularType, diagonal: Int) -> SparseMatrix<Scalar> {
    Self()
  }


//  MARK: Unary Operators

  public static func negate(_ lhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    var out = Self(lhs._spmat)
    out._values = lhs._values.map { -$0 }
    return out
  }

  public func abs() -> SparseMatrix<Scalar> {
    var out = Self(_spmat)
    out._values = LinAlg.abs(_values)
    return out
  }

  public func max() -> (Scalar, RowCol)? {
    guard let m = _values.max() else { return nil }
    return (m, valueIndexToRowColumn(_values.firstIndex(of: m)!))
  }

  public func min() -> (Scalar, RowCol)? {
    guard let m = _values.min() else { return nil }
    return (m, valueIndexToRowColumn(_values.firstIndex(of: m)!))
  }

  public func sum() -> Scalar {
    _values.sum()
  }

  public func mean<R>() -> R where R: SwivlFloatingPoint {
    self.to(type: R.self).mean()
  }

  public func square() -> SparseMatrix<Scalar> {
    var out = Self(_spmat)
    out._values = _values.map { $0*$0 }
    return out
  }


//  MARK: Arithmetic

  public static func add(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self(LinAlg.add(lhs._spmat, rhs._spmat))
  }

  public static func add(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self.init(
      rowIndices: lhs._rowIndices,
      columnStarts: lhs._columnStarts,
      LinAlg.addScalar(lhs._values, rhs),
      lhs.rows, lhs.cols)
  }

  public static func subtract(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self(LinAlg.subtract(lhs._spmat, rhs._spmat))
  }

  public static func subtract(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self.init(
      rowIndices: lhs._rowIndices,
      columnStarts: lhs._columnStarts,
      LinAlg.subtractScalar(lhs._values, rhs),
      lhs.rows, lhs.cols)
  }

  public static func multiplyElements(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self(LinAlg.multiplyElementwise(lhs._spmat, rhs._spmat))
  }

  public static func multiplyElements(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self.init(
      rowIndices: lhs._rowIndices,
      columnStarts: lhs._columnStarts,
      lhs._values.map { $0 * rhs },
      lhs.rows, lhs.cols)
  }

  public static func divideElements(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self(LinAlg.divideElementwise(lhs._spmat, rhs._spmat))
  }

  public static func divideElements(_ lhs: SparseMatrix<Scalar>, _ rhs: Scalar) -> SparseMatrix<Scalar> {
    Self.init(
      rowIndices: lhs._rowIndices,
      columnStarts: lhs._columnStarts,
      LinAlg.divideScalar(lhs._values, rhs),
      lhs.rows, lhs.cols)
  }

  public static func multiplyMatrix(_ lhs: SparseMatrix<Scalar>, _ rhs: SparseMatrix<Scalar>) -> SparseMatrix<Scalar> {
    Self(LinAlg.multiplyMatrix(lhs._spmat, rhs._spmat))
  }


//  MARK: Matrix Creation

  public static func zeros(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func ones(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self(LinAlg.sparseOnes(rows, cols))
  }

//  TODO
  public static func rand(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

//  TOOD
  public static func randn(_ rows: Int, _ cols: Int) -> SparseMatrix<Scalar> {
    Self()
  }

  public static func eye(_ n: Int) -> SparseMatrix<Scalar> {
    Self(rowIndices: Array(0..<Int32(n)), columnStarts: Array(0...n), [Scalar](repeating: 1, count: n))
  }


//  MARK: Conversion

  public func dense() -> Matrix<Scalar> {
    Matrix(LinAlg.CSCToDense(_spmat))
  }

  public func triplets() -> (Vector<Int>, Vector<Int>, Vector<Scalar>) {
    let (rc,v) = LinAlg.CSCToTriplet(_spmat)
    return (Vector(rc.map(\.r)), Vector(rc.map(\.c)), Vector(v))
  }

  public func vector<V: VectorProtocol>() -> V where V.Scalar == Scalar {
    precondition(rows == 1 || cols == 1)
    if rows == 1 {
      return V(LinAlg.row(_spmat, 0))
    } else {
      return V(LinAlg.col(_spmat, 0))
    }
  }

  public func to<U>(type: U.Type) -> SparseMatrix<U> where U: SwivlNumeric {
    SparseMatrix<U>(rowIndices: _rowIndices, columnStarts: _columnStarts, LinAlg.toType(_values, type), rows, cols)
  }

}
