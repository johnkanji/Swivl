//  SparseCreation.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

  public static func sparseOnes<T>(_ rows: Int, _ cols: Int) -> SpMat<T> where T: SwivlNumeric {
    let ri = (0..<cols).map { _ in Array(Int32(0)..<Int32(rows)) }.chained()
    let cs = (0..<cols+1).map { $0*rows }
    let v = [T](repeating: 1, count: rows*cols)
    return SpMat(ri, cs, v, (rows, cols))
  }

  public static func sparseRand<T>(_ rows: Int, _ cols: Int) -> SpMat<T> where T: SwivlFloatingPoint {
    let ri = (0..<cols).map { _ in Array(Int32(0)..<Int32(rows)) }.chained()
    let cs = (0..<cols+1).map { $0*rows }
    let v: [T] = Self.rand(rows * cols)
    return SpMat(ri, cs, v, (rows, cols))
  }

  public static func sparseRandn<T>(_ rows: Int, _ cols: Int) -> SpMat<T> where T: SwivlFloatingPoint {
    let ri = (0..<cols).map { _ in Array(Int32(0)..<Int32(rows)) }.chained()
    let cs = (0..<cols+1).map { $0*rows }
    let v: [T] = Self.randn(rows * cols)
    return SpMat(ri, cs, v, (rows, cols))
  }

}
