//  SparseMatrix+Subscript.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension SparseMatrix {
  //  TODO: Subscript assignments

  // Index Type combinations and selection strategies:
  //    row/col      |   Index   |   [Index]   |   Range   | UnboundedRange
  //-----------------|-----------|-------------|-----------|----------------
  //  Index          | subscript | gather      | block     | row/col
  //  [Index]        | gather    | gather      | cat block | cat row/col
  //  Range          | block     | cat block   | block     | block
  //  UnboundedRange | row/col   | cat row/col | block     | all
  //
  //  Index/Index implemented in SparseMatrix.swift


  //  MARK: Index/[Index]

  public subscript(_ rows: Index, _ cols: Vector<Index>) -> Vector<Scalar> {
    Vector(LinAlg.gather(LinAlg.row(_spmat, rows), cols.array), shape: (1, cols.count))
  }
  public subscript(_ rows: Vector<Index>, _ cols: Index) -> Vector<Scalar> {
    Vector(LinAlg.gather(LinAlg.col(_spmat, cols), rows.array), shape: (rows.count, 1))
  }


  //  MARK: Index/Range

  public subscript<R>(_ rows: Index, _ cols: R) -> Vector<Scalar>
  where R: RangeExpression, R.Bound == Int {
    let array = Array(LinAlg.row(_spmat, rows)[cols])
    return Vector(array, shape: (1, array.count))
  }
  public subscript<R>(_ rows: R, _ cols: Index) -> Vector<Scalar>
  where R: RangeExpression, R.Bound == Int {
    let array = Array(LinAlg.col(_spmat, cols)[rows])
    return Vector(array, shape: (array.count, 1))
  }


  //  MARK: Index/...

  public subscript(_ rows: Index, _ cols: UnboundedRange) -> Vector<Scalar> {
    Vector(LinAlg.row(_spmat, rows), shape: (1, self.cols))
  }
  public subscript(_ rows: UnboundedRange, _ cols: Index) -> Vector<Scalar> {
    Vector(LinAlg.col(_spmat, cols), shape: (self.rows, 1))
  }


  // MARK: [Index]/[Index]

  public subscript(_ rows: Vector<Index>, _ cols: Vector<Index>) -> Self {
    Self(LinAlg.sparseGather(_spmat, rows.array, cols.array))
  }


  //  MARK: [Index]/Range

  public subscript<R>(_ rows: Vector<Index>, _ cols: R) -> Self where R: RangeExpression, R.Bound == Int {
    let cols: [Int] = Array(indexRange(cols, for: .col))
    return Self(LinAlg.sparseGather(_spmat, rows.array, cols))
  }
  public subscript<R>(_ rows: R, _ cols: Vector<Index>) -> Self where R: RangeExpression {
    let rows: [Int] = Array(indexRange(rows, for: .row))
    return Self(LinAlg.sparseGather(_spmat, rows, cols.array))
  }


  //  MARK: [Index]/...

  public subscript(_ rows: Vector<Index>, _ cols: UnboundedRange) -> Self {
    Self(LinAlg.vcat(rows.map { r in LinAlg.sparseRow(_spmat, r) }))
  }
  public subscript(_ rows: UnboundedRange, _ cols: Vector<Index>) -> Self {
    Self(LinAlg.hcat(cols.map { c in LinAlg.sparseCol(_spmat, c) }))
  }


  //  MARK: Range/Range

  public subscript<R1, R2>(_ rows: R1, _ cols: R2) -> Self
  where R1: RangeExpression, R2: RangeExpression {
    let r1 = indexRange(rows, for: .row)
    let r2 = indexRange(cols, for: .col)
    precondition(r1.upperBound < self.rows && r2.upperBound < self.cols, "Index out of range")
    let startIndex = RowCol(r1.lowerBound, r2.lowerBound)
    let shapeOut = RowCol((r1.upperBound - r1.lowerBound) + 1, (r2.upperBound - r2.lowerBound) + 1)
    return Self(LinAlg.block(_spmat, startIndex: startIndex, shapeOut: shapeOut))
  }


  //  MARK: Range/...

  public subscript<R>(_ rows: R, _ cols: UnboundedRange) -> Self where R: RangeExpression {
    let r = indexRange(rows, for: .row)
    precondition(r.upperBound < self.rows, "Index out of range")
    let shapeOut = RowCol((r.upperBound - r.lowerBound) + 1, self.cols)
    return Self(LinAlg.block(_spmat, startIndex: (r.lowerBound,0), shapeOut: shapeOut))
  }
  public subscript<R>(_ rows: UnboundedRange, _ cols: R) -> Self where R: RangeExpression {
    let r = indexRange(cols, for: .col)
    precondition(r.upperBound < self.cols, "Index out of range")
    let shapeOut = RowCol(self.rows, (r.upperBound - r.lowerBound) + 1)
    return Self(LinAlg.block(_spmat, startIndex: (0, r.lowerBound), shapeOut: shapeOut))
  }


  //  MARK: .../...

  public subscript(_ rows: UnboundedRange, _ cols: UnboundedRange) -> Self {
    Self(_spmat)
  }


//  MARK: Util

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
