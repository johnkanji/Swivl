//  Matrix+Subscript.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Matrix {
  //  TODO: Subscript assignments
  
// Index Type combinations and selection strategies:
//    row/col      |   Index   |   [Index]   |   Range   | UnboundedRange
//-----------------|-----------|-------------|-----------|----------------
//  Index          | subscript | gather      | block     | row/col
//  [Index]        | gather    | gather      | cat block | cat row/col
//  Range          | block     | cat block   | block     | block
//  UnboundedRange | row/col   | cat row/col | block     | all
//  
//  Index/Index implemented in Matrix.swift


//  MARK: Index/[Index]
  public subscript(_ rows: Index, _ cols: Vector<Index>) -> Vector<Scalar> {
    get {
      let indices = cols.map { c in (rows, c) }.map(self.rowColumnToFlatIndex)
      return Vector(LinAlg.gather(flat, indices))
    }
    set {
      precondition(newValue.count == cols.count, "Dimensions do not match")
      let ri = [Int](repeating: rows, count: cols.count)
      LinAlg.scatter(&_flat, shape, newValue.array, ri, cols.array)
    }
  }
  public subscript(_ rows: Vector<Index>, _ cols: Index) -> Vector<Scalar> {
    get {
      let indices = rows.map { r in (cols, r) }.map(self.rowColumnToFlatIndex)
      return Vector(LinAlg.gather(flat, indices))
    }
    set {
      precondition(newValue.count == rows.count, "Dimensions do not match")
      let ci = [Int](repeating: cols, count: rows.count)
      LinAlg.scatter(&_flat, shape, newValue.array, rows.array, ci)
    }
  }
  
  
//  MARK: Index/Range
  public subscript<R>(_ rows: Index, _ cols: R) -> Vector<Scalar>
  where R: RangeExpression {
    get {
      let blk = colBlock(rows, cols)
      return Vector(blk.flat)
    }
    set {
      let r = indexRange(cols, for: .col)
      precondition(r.count == newValue.count, "Dimensions do not match")
      LinAlg.setBlock(&_flat, shape, (newValue.array, (1, newValue.count)), startIndex: (rows, r.lowerBound))
    }
  }
  public subscript<R>(_ rows: R, _ cols: Index) -> Vector<Scalar>
  where R: RangeExpression {
    get {
      let blk = rowBlock(rows, cols)
      return Vector(blk.flat)
    }
    set {
      let r = indexRange(rows, for: .row)
      precondition(r.count == newValue.count, "Dimensions do not match")
      LinAlg.setBlock(&_flat, shape, (newValue.array, (newValue.count, 1)), startIndex: (r.lowerBound, cols))
    }
  }
  
  
//  MARK: Index/...
  public subscript(_ rows: Index, _ cols: UnboundedRange) -> Vector<Scalar> {
    get { Vector(LinAlg.row(_mat, rows)) }
    set { LinAlg.setRow(&_flat, shape, newValue.array, rows) }
  }
  public subscript(_ rows: UnboundedRange, _ cols: Index) -> Vector<Scalar> {
    get { Vector(LinAlg.col(_mat, cols)) }
    set { LinAlg.setCol(&_flat, shape, newValue.array, cols) }
  }
  
  
// MARK: [Index]/[Index]
  public subscript(_ rows: Vector<Index>, _ cols: Vector<Index>) -> Self {
    get {
      let indices = rows.map { r in cols.map { c in RowCol(r, c) } }.chained().map(rowColumnToFlatIndex)
      return Self(flat: LinAlg.gather(flat, indices), shape: (rows.count, cols.count))
    }
    set {
      precondition(newValue.rows == rows.count && newValue.cols == cols.count, "Dimensions do not match")
      precondition(rows.min()! >= 0 && rows.max()! < self.rows && cols.min()! >= 0 && cols.max()! < self.cols,
                   "Index out of range")
      let rc: [RowCol] = (0..<newValue.count).map { i in
        let rc = newValue.flatIndexToRowColumn(i)
        return RowCol(rows[rc.r], cols[rc.c])
      }
      LinAlg.scatter(&_flat, shape, newValue._flat, rc.map(\.r), rc.map(\.c))
    }
  }
  
  
//  MARK: [Index]/Range
  public subscript<R>(_ rows: Vector<Index>, _ cols: R) -> Self where R: RangeExpression {
    get {
      let vs = rows.map { r in colBlock(r, cols) }
      return Self(LinAlg.vcat(vs))
    }
    set {
      let r = indexRange(cols, for: .col)
      self[rows, Vector(Array(r))] = newValue
    }
  }
  public subscript<R>(_ rows: R, _ cols: Vector<Index>) -> Self where R: RangeExpression {
    get {
      let vs = cols.map { c in rowBlock(rows, c) }
      return Self(LinAlg.hcat(vs))
    }
    set {
      let r = indexRange(rows, for: .row)
      self[Vector(Array(r)), cols] = newValue
    }
  }
  
  
//  MARK: [Index]/...
  public subscript(_ rows: Vector<Index>, _ cols: UnboundedRange) -> Self {
    get {
      let shapes = [RowCol](repeating: (1, self.cols), count: rows.count)
      let v = LinAlg.vcat(Array(zip(rows.map { r in LinAlg.row(_mat, r) }, shapes)))
      return Self(v)
    }
    set {
      precondition(newValue.rows == rows.count && newValue.cols == self.cols, "Dimensions do not match")
      for r in (0..<newValue.rows) {
        self[rows[r],...] = newValue[r,...]
      }
    }
  }
  public subscript(_ rows: UnboundedRange, _ cols: Vector<Index>) -> Self {
    get {
      let shapes = [RowCol](repeating: (self.rows, 1), count: cols.count)
      let v = LinAlg.hcat(Array(zip(cols.map { c in LinAlg.col(_mat, c) }, shapes)))
      return Self(v)
    }
    set {
      precondition(newValue.rows == self.rows && newValue.cols == cols.count, "Dimensions do not match")
      for c in (0..<newValue.cols) {
        self[...,cols[c]] = newValue[...,c]
      }
    }
  }
  
  
//  MARK: Range/Range
  public subscript<R1, R2>(_ rows: R1, _ cols: R2) -> Self
  where R1: RangeExpression, R2: RangeExpression {
    get {
      let r1 = indexRange(rows, for: .row)
      let r2 = indexRange(cols, for: .col)
      precondition(r1.upperBound < self.rows && r2.upperBound < self.cols, "Index out of range")
      let startIndex = RowCol(r1.lowerBound, r2.lowerBound)
      let shapeOut = RowCol((r1.upperBound - r1.lowerBound) + 1, (r2.upperBound - r2.lowerBound) + 1)
      return Self(LinAlg.block(_mat, startIndex: startIndex, shapeOut: shapeOut))
    }
    set {
      let r1 = indexRange(rows, for: .row)
      let r2 = indexRange(cols, for: .col)
      precondition(r1.count == newValue.rows && r2.count == newValue.cols, "Dimensions do not match")
      LinAlg.setBlock(&_flat, shape, newValue._mat, startIndex: (r1.lowerBound,r2.lowerBound))
    }
  }
  
  
//  MARK: Range/...
  public subscript<R>(_ rows: R, _ cols: UnboundedRange) -> Self where R: RangeExpression {
    get  {
      let r = indexRange(rows, for: .row)
      precondition(r.upperBound < self.rows, "Index out of range")
      let shapeOut = RowCol((r.upperBound - r.lowerBound) + 1, self.cols)
      return Self(LinAlg.block(_mat, startIndex: (r.lowerBound,0), shapeOut: shapeOut))
    }
    set {
      let r = indexRange(rows, for: .row)
      precondition(r.count == newValue.rows && self.cols == newValue.cols, "Dimensions do not match")
      LinAlg.setBlock(&_flat, shape, newValue._mat, startIndex: (r.lowerBound,0))
    }
  }
  public subscript<R>(_ rows: UnboundedRange, _ cols: R) -> Self where R: RangeExpression {
    get {
      let r = indexRange(cols, for: .col)
      precondition(r.upperBound < self.cols, "Index out of range")
      let shapeOut = RowCol(self.rows, (r.upperBound - r.lowerBound) + 1)
      return Self(LinAlg.block(_mat, startIndex: (0, r.lowerBound), shapeOut: shapeOut))
    }
    set {
      let r = indexRange(cols, for: .col)
      precondition(r.count == newValue.cols && self.rows == newValue.rows, "Dimensions do not match")
      LinAlg.setBlock(&_flat, shape, newValue._mat, startIndex: (0,r.lowerBound))
    }
  }
  
  
//  MARK: .../...
  public subscript(_ rows: UnboundedRange, _ cols: UnboundedRange) -> Self {
    get {
      Self(flat: flat, shape: shape)
    }
    set {
      precondition(shape == newValue.shape, "Dimensions do not match")
      _flat = newValue._flat
    }
  }


//  MARK: Utils

  private func rowBlock<R>(_ rows: R, _ cols: Index) -> Mat<Scalar> where R: RangeExpression {
    let range = indexRange(rows, for: .row)
    precondition(range.upperBound < self.rows, "Index out of range")
    let shapeOut = RowCol((range.upperBound - range.lowerBound) + 1, 1)
    return LinAlg.block(_mat, startIndex: (range.lowerBound, cols), shapeOut: shapeOut)
  }
  private func colBlock<R>(_ rows: Index, _ cols: R) -> Mat<Scalar> where R: RangeExpression {
    let range = indexRange(cols, for: .col)
    precondition(range.upperBound < self.cols, "Index out of range")
    let shapeOut = RowCol(1, (range.upperBound - range.lowerBound) + 1)
    return LinAlg.block(_mat, startIndex: (rows, range.lowerBound), shapeOut: shapeOut)
  }
  
  private func indexRange<R>(_ range: R, for d: MatrixDimension) -> ClosedRange<Index> where R: RangeExpression {
    if R.self is ClosedRange<Index>.Type {
      return range as! ClosedRange<Index>
    } else if R.self is Range<Index>.Type {
      return ClosedRange(range as! Range)
    } else if R.self is PartialRangeFrom<Index>.Type {
      let r = range as! PartialRangeFrom<Index>
      return ClosedRange(uncheckedBounds: (r.lowerBound, (d == .row ? rows : cols) - 1))
    } else if R.self is PartialRangeThrough<Index>.Type {
      let r = range as! PartialRangeThrough<Index>
      return ClosedRange(uncheckedBounds: (0, r.upperBound))
    } else {
      let r = range as! PartialRangeUpTo<Index>
      return ClosedRange(uncheckedBounds: (0, r.upperBound))
    }
  }
}
