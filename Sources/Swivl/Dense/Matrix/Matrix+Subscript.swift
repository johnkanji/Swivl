//  Matrix+Subscript.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

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
  public subscript(_ rows: Index, _ cols: [Index]) -> Vector<Scalar> {
    let indices = cols.map { c in (rows, c) }.map(self.rowColumnToFlatIndex)
    return Vector(BLAS.gather(flat, indices), shape: (1, cols.count))
  }
  public subscript(_ rows: [Index], _ cols: Index) -> Vector<Scalar> {
    let indices = rows.map { r in (cols, r) }.map(self.rowColumnToFlatIndex)
    return Vector(BLAS.gather(flat, indices), shape: (rows.count, 1))
  }
  
  
//  MARK: Index/Range
  private func rowBlock<R>(_ rows: R, _ cols: Index) -> [Scalar] where R: RangeExpression {
    let range = indexRange(rows, for: .row)
    precondition(range.upperBound < self.rows, "Index out of range")
    let shapeOut = RowCol((range.upperBound - range.lowerBound) + 1, 1)
    return BLAS.block(flat, shape, startIndex: (range.lowerBound, cols), shapeOut: shapeOut)
  }
  private func colBlock<R>(_ rows: Index, _ cols: R) -> [Scalar] where R: RangeExpression {
    let range = indexRange(cols, for: .col)
    precondition(range.upperBound < self.cols, "Index out of range")
    let shapeOut = RowCol(1, (range.upperBound - range.lowerBound) + 1)
    return BLAS.block(flat, shape, startIndex: (rows, range.lowerBound), shapeOut: shapeOut)
  }
  
  public subscript<R>(_ rows: Index, _ cols: R) -> Vector<Scalar>
  where R: RangeExpression {
    let blk = colBlock(rows, cols)
    return Vector(blk, shape: (blk.count, 1))
  }
  public subscript<R>(_ rows: R, _ cols: Index) -> Vector<Scalar>
  where R: RangeExpression {
    let blk = rowBlock(rows, cols)
    return Vector(blk, shape: (1, blk.count))
  }
  
  
//  MARK: Index/...
  public subscript(_ rows: Index, _ cols: UnboundedRange) -> Vector<Scalar> {
    Vector(BLAS.row(flat, shape, rows), shape: (1, self.cols))
  }
  public subscript(_ rows: UnboundedRange, _ cols: Index) -> Vector<Scalar> {
    Vector(BLAS.col(flat, shape, cols), shape: (self.rows, 1))
  }
  
  
// MARK: [Index]/[Index]
  public subscript(_ rows: [Index], _ cols: [Index]) -> Self {
    let indices = rows.map { r in cols.map { c in RowCol(r, c) } }.reduce([], +).map(rowColumnToFlatIndex)
    return Self(flat: BLAS.gather(flat, indices), shape: (rows.count, cols.count))
  }
  
  
//  MARK: [Index]/Range
  public subscript<R>(_ rows: [Index], _ cols: R) -> Self where R: RangeExpression {
    let vs = rows.map { r in colBlock(r, cols) }
    let shapes = [RowCol](repeating: RowCol(1, vs[0].count), count: vs.count)
    return Self(flat: BLAS.vcat(vs, shapes: shapes), shape: (rows.count, vs[0].count))
  }
  public subscript<R>(_ rows: R, _ cols: [Index]) -> Self where R: RangeExpression {
    let vs = cols.map { c in rowBlock(rows, c) }
    let shapes = [RowCol](repeating: RowCol(vs[0].count, 1), count: vs.count)
    return Self(flat: BLAS.hcat(vs, shapes: shapes), shape: (vs[0].count, cols.count))
  }
  
  
//  MARK: [Index]/...
  public subscript(_ rows: [Index], _ cols: UnboundedRange) -> Self {
    let v = BLAS.vcat(
      rows.map { r in BLAS.row(flat, shape, r) },
      shapes: [RowCol](repeating: (1, self.cols), count: rows.count))
    return Self(flat: v, shape: (rows.count, self.cols))
  }
  public subscript(_ rows: UnboundedRange, _ cols: [Index]) -> Self {
    let v = BLAS.hcat(
      cols.map { c in BLAS.col(flat, shape, c) },
      shapes: [RowCol](repeating: (self.rows, 1), count: cols.count))
    return Self(flat: v, shape: (self.rows, cols.count))
  }
  
  
//  MARK: Range/Range
  public subscript<R1, R2>(_ rows: R1, _ cols: R2) -> Self
  where R1: RangeExpression, R2: RangeExpression {
    let r1 = indexRange(rows, for: .row)
    let r2 = indexRange(cols, for: .col)
    precondition(r1.upperBound < self.rows && r2.upperBound < self.cols, "Index out of range")
    let startIndex = RowCol(r1.lowerBound, r2.lowerBound)
    let shapeOut = RowCol((r1.upperBound - r1.lowerBound) + 1, (r2.upperBound - r2.lowerBound) + 1)
    return Self(flat: BLAS.block(flat, shape, startIndex: startIndex, shapeOut: shapeOut), shape: shapeOut)
  }
  
  
//  MARK: Range/...
  public subscript<R>(_ rows: R, _ cols: UnboundedRange) -> Self where R: RangeExpression {
    let r = indexRange(rows, for: .row)
    precondition(r.upperBound < self.rows, "Index out of range")
    let shapeOut = RowCol((r.upperBound - r.lowerBound) + 1, self.cols)
    return Self(flat: BLAS.block(flat, shape, startIndex: (r.lowerBound,0), shapeOut: shapeOut), shape: shapeOut)
  }
  public subscript<R>(_ rows: UnboundedRange, _ cols: R) -> Self where R: RangeExpression {
    let r = indexRange(cols, for: .col)
    precondition(r.upperBound < self.cols, "Index out of range")
    let shapeOut = RowCol(self.rows, (r.upperBound - r.lowerBound) + 1)
    return Self(flat: BLAS.block(flat, shape, startIndex: (0, r.lowerBound), shapeOut: shapeOut), shape: shapeOut)
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
