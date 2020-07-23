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
    let indices = cols.map { c in (rows, c) }.map(self.rowColumnToFlatIndex)
    return Vector(LinAlg.gather(flat, indices), shape: (1, cols.count))
  }
  public subscript(_ rows: Vector<Index>, _ cols: Index) -> Vector<Scalar> {
    let indices = rows.map { r in (cols, r) }.map(self.rowColumnToFlatIndex)
    return Vector(LinAlg.gather(flat, indices), shape: (rows.count, 1))
  }
  
  
//  MARK: Index/Range
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
  
  public subscript<R>(_ rows: Index, _ cols: R) -> Vector<Scalar>
  where R: RangeExpression {
    let blk = colBlock(rows, cols)
    return Vector(blk.flat, shape: blk.shape)
  }
  public subscript<R>(_ rows: R, _ cols: Index) -> Vector<Scalar>
  where R: RangeExpression {
    let blk = rowBlock(rows, cols)
    return Vector(blk.flat, shape: blk.shape)
  }
  
  
//  MARK: Index/...
  public subscript(_ rows: Index, _ cols: UnboundedRange) -> Vector<Scalar> {
    Vector(LinAlg.row(_mat, rows), shape: (1, self.cols))
  }
  public subscript(_ rows: UnboundedRange, _ cols: Index) -> Vector<Scalar> {
    Vector(LinAlg.col(_mat, cols), shape: (self.rows, 1))
  }
  
  
// MARK: [Index]/[Index]
  public subscript(_ rows: Vector<Index>, _ cols: Vector<Index>) -> Self {
    let indices = rows.map { r in cols.map { c in RowCol(r, c) } }.chained().map(rowColumnToFlatIndex)
    return Self(flat: LinAlg.gather(flat, indices), shape: (rows.count, cols.count))
  }
  
  
//  MARK: [Index]/Range
  public subscript<R>(_ rows: Vector<Index>, _ cols: R) -> Self where R: RangeExpression {
    let vs = rows.map { r in colBlock(r, cols) }
    return Self(LinAlg.vcat(vs))
  }
  public subscript<R>(_ rows: R, _ cols: Vector<Index>) -> Self where R: RangeExpression {
    let vs = cols.map { c in rowBlock(rows, c) }
    return Self(LinAlg.hcat(vs))
  }
  
  
//  MARK: [Index]/...
  public subscript(_ rows: Vector<Index>, _ cols: UnboundedRange) -> Self {
    let shapes = [RowCol](repeating: (1, self.cols), count: rows.count)
    let v = LinAlg.vcat(Array(zip(rows.map { r in LinAlg.row(_mat, r) }, shapes)))
    return Self(v)
  }
  public subscript(_ rows: UnboundedRange, _ cols: Vector<Index>) -> Self {
    let shapes = [RowCol](repeating: (self.rows, 1), count: cols.count)
    let v = LinAlg.hcat(Array(zip(cols.map { c in LinAlg.col(_mat, c) }, shapes)))
    return Self(v)
  }
  
  
//  MARK: Range/Range
  public subscript<R1, R2>(_ rows: R1, _ cols: R2) -> Self
  where R1: RangeExpression, R2: RangeExpression {
    let r1 = indexRange(rows, for: .row)
    let r2 = indexRange(cols, for: .col)
    precondition(r1.upperBound < self.rows && r2.upperBound < self.cols, "Index out of range")
    let startIndex = RowCol(r1.lowerBound, r2.lowerBound)
    let shapeOut = RowCol((r1.upperBound - r1.lowerBound) + 1, (r2.upperBound - r2.lowerBound) + 1)
    return Self(LinAlg.block(_mat, startIndex: startIndex, shapeOut: shapeOut))
  }
  
  
//  MARK: Range/...
  public subscript<R>(_ rows: R, _ cols: UnboundedRange) -> Self where R: RangeExpression {
    let r = indexRange(rows, for: .row)
    precondition(r.upperBound < self.rows, "Index out of range")
    let shapeOut = RowCol((r.upperBound - r.lowerBound) + 1, self.cols)
    return Self(LinAlg.block(_mat, startIndex: (r.lowerBound,0), shapeOut: shapeOut))
  }
  public subscript<R>(_ rows: UnboundedRange, _ cols: R) -> Self where R: RangeExpression {
    let r = indexRange(cols, for: .col)
    precondition(r.upperBound < self.cols, "Index out of range")
    let shapeOut = RowCol(self.rows, (r.upperBound - r.lowerBound) + 1)
    return Self(LinAlg.block(_mat, startIndex: (0, r.lowerBound), shapeOut: shapeOut))
  }
  
  
//  MARK: .../...
  public subscript(_ rows: UnboundedRange, _ cols: UnboundedRange) -> Self {
    Self(flat: flat, shape: shape)
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
