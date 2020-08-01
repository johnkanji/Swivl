//  SparseConversion.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

  public static func tripletToCSC<T>(_ ri: [Int], _ ci: [Int], _ v: [T], shape: RowCol? = nil) -> SpMat<T>
  where T: SwivlNumeric {
    let nr = shape?.r ?? Int(ri.max()! + 1)
    let nc = shape?.c ?? Int(ci.max()! + 1)

    let comp: (RowCol, RowCol) -> Bool = { a, b in (a.c < b.c) || (a.c == b.c && a.r <= b.r) }
    let rowsCols = zip(zip(ri, ci), v).map({ (RowCol($0.0.0,$0.0.1), $0.1) }).sorted(by: { comp($0.0, $1.0) })
    let ri = rowsCols.map { Int32($0.0.r) }
    let ci = rowsCols.map { $0.0.c }
    let cs = ci.reduce(into: [Int](repeating: 0, count: nc)) { acc, c in acc[c] += 1 }.cumsum()
    let vs = rowsCols.map { $0.1 }
    return (ri, cs, vs, RowCol(nr, nc))
  }

  public static func CSCToTriplet<T>(_ a: SpMat<T>) -> (rcs: [RowCol], v: [T]) where T: SwivlNumeric {
    let rcs: [RowCol] = a.ri.enumerated().map { i, r in
      let c = a.cs.lastIndex(where: { ci in ci < i }) ?? 0
      return RowCol(Int(r), c)
    }
    return (rcs, a.v)
  }


  public static func denseToCSC<T>(_ a: Mat<T>) -> SpMat<T>
  where T: SwivlNumeric {
    let rcs = a.flat.enumerated().filter { i, v in v != 0 }.map { i, v -> RowCol in
      let r = i / a.shape.c
      let c = i - (r*a.shape.c)
      return RowCol(r, c)
    }
    let v = a.flat.filter { $0 != 0 }
    return tripletToCSC(rcs.map(\.r), rcs.map(\.c), v, shape: a.shape)
  }


  public static func CSCToDense<T>(_ a: SpMat<T>) -> Mat<T> where T: SwivlNumeric {
    var m = [T](repeating: 0, count: a.shape.r*a.shape.c)
    a.v.enumerated().forEach { vi, v in
      let r = Int(a.ri[vi])
      let c = a.cs.lastIndex(where: { c in c <= vi }) ?? 0
      let mi = r*a.shape.c + c
      m[mi] = v
    }
    return (m, a.shape)
  }


}
