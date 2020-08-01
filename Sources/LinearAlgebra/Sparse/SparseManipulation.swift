//  SparseManipulation.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

//  MARK: Transpose

  public static func transpose<T>(_ a: SpMat<T>) -> SpMat<T> {
    var ri: [Int32] = []
    ri.reserveCapacity(a.ri.count)
    var cs: [Int] = [0]
    var v: [T] = []
    v.reserveCapacity(a.v.count)

    let ciOut = Set(a.ri).sorted()
    cs.reserveCapacity(ciOut.count + 1)

    for cOut in ciOut {
      for cIn in 0..<a.shape.c {
        let riIn = a.ri[a.cs[cIn]..<a.cs[cIn+1]]
        if let ii = binarySearch(riIn, for: cOut) {
          ri.append(Int32(cIn))
          v.append(a.v[ii])
        }
      }
      cs.append(ri.count)
    }

    return (ri, cs, v, (a.shape.c, a.shape.r))
  }


//  MARK: Extraction

  public static func row<T>(_ a: SpMat<T>, _ r: Int) -> [T] where T: SwivlNumeric {
    precondition(r >= 0 && r < a.shape.r)

    let r = Int32(r)
    var row = [T](repeating: 0, count: a.shape.c)
    (0..<a.shape.c).forEach { c in
      let ris = a.ri[a.cs[c]..<a.cs[c+1]]
      if let i = ris.firstIndex(of: r) {
        row[c] = a.v[a.cs[c] + i]
      }
    }
    return row
  }

  public static func col<T>(_ a: SpMat<T>, _ c: Int) -> [T] where T: SwivlNumeric {
    precondition(c >= 0 && c < a.shape.c)

    var col = [T](repeating: 0, count: a.shape.r)
    zip(a.ri[a.cs[c]..<a.cs[c+1]], a.v[a.cs[c]..<a.cs[c+1]]).forEach { ri, v in
      col[Int(ri)] = v
    }
    return col
  }


  public static func sparseRow<T>(_ a: SpMat<T>, _ r: Int) -> SpMat<T> {
    precondition(r >= 0 && r < a.shape.r)

    var ri: [Int32] = []
    var cs: [Int] = []
    var v: [T] = []
    (0..<a.shape.c).forEach { c in
      let ris = a.ri[a.cs[c]..<a.cs[c+1]]
      if let i = ris.firstIndex(of: Int32(r)) {
        ri.append(0)
        v.append(a.v[a.cs[c] + i])
      }
      cs.append(ri.count)
    }
    return SpMat(ri, cs, v, (1, a.shape.c))
  }

  public static func sparseCol<T>(_ a: SpMat<T>, _ c: Int) -> SpMat<T> {
    precondition(c >= 0 && c < a.shape.c)
    let rng = a.cs[c]..<a.cs[c+1]
    let ri = Array(a.ri[rng])
    let cs = [0, ri.count]
    let v = Array(a.v[rng])
    return SpMat(ri, cs, v, (a.shape.r, 1))
  }


  public static func block<T>(_ a: SpMat<T>, startIndex: RowCol, shapeOut: RowCol) -> SpMat<T>
  where T: SwivlNumeric {
    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []

    (startIndex.c..<(startIndex.c + shapeOut.c)).forEach { c in
      let rv = zip(a.ri[a.cs[c]..<a.cs[c+1]], a.v[a.cs[c]..<a.cs[c+1]])
        .filter { $0.0 >= startIndex.r && $0.0 < (startIndex.r + shapeOut.r) }
      rv.forEach {
        ri.append($0.0 - Int32(startIndex.r))
        v.append($0.1)
      }
      cs.append(ri.count)
    }
    return SpMat(ri, cs, v, shapeOut)
  }


  public static func sparseGather<T>(_ a: SpMat<T>, _ riis: [Int], _ ciis: [Int]) -> SpMat<T>
  where T: SwivlNumeric {
    var ri: [Int32] = []
    var cs: [Int] = [0]
    cs.reserveCapacity(ciis.count + 1)
    var v: [T] = []

    ciis.forEach { cii in
      let ris = a.ri[a.cs[cii]..<a.cs[cii+1]]
      riis.enumerated().forEach { riiOut, riiIn in
        if let i = ris.firstIndex(of: Int32(riiIn)) {
          ri.append(Int32(riiOut))
          v.append(a.v[a.cs[cii + i]])
        }
      }
      cs.append(ri.count)
    }
    return SpMat(ri, cs, v, RowCol(riis.count, ciis.count))
  }


  public static func diag<T>(_ a: SpMat<T>) -> [T] where T: SwivlNumeric {
    (0..<Swift.min(a.shape.r, a.shape.c)).map { i in
      if let vi = Self.rowColToValueIndex(a, (i,i)) { return a.v[vi] }
      else { return 0 }
    }
  }


//  MARK: Insertion
//  Insertion methods do not use the SpMat typealias in order to take advantage
//  of pass-by-reference semantics of inout arrays.

  public static func insert<T>(
    _ ri: inout [Int32], _ cs: inout [Int], _ v: inout [T], _ shape: RowCol, _ i: RowCol, _ newVal: T)
  where T: SwivlNumeric {
    let vi = ri[cs[i.c]..<cs[i.c+1]].firstIndex(where: { $0 >= Int32(i.r) })
    if vi == nil {
      ri.insert(Int32(i.r), at: cs[i.c])
      v.insert(newVal, at: cs[i.c])
      ((i.c+1)..<cs.count).forEach { ci in cs[ci] += 1 }
    } else if ri[vi!] == i.r {
      v[vi!] = newVal
    } else {
      ri.insert(Int32(i.r), at: vi!)
      v.insert(newVal, at: vi!)
      ((i.c+1)..<cs.count).forEach { ci in cs[ci] += 1 }
    }
  }


//  MARK: Concatenation

  public static func hcat<T>(_ ms: [SpMat<T>]) -> SpMat<T> where T: SwivlNumeric {
    precondition(ms.allSatisfy { $0.shape.r == ms[0].shape.r })
    let shapeOut = RowCol(ms[0].shape.r, ms.map { $0.shape.c }.sum())

    let ri = ms.map(\.ri).chained()
    let v = ms.map(\.v).chained()
    var cs: [Int] = [0]
    cs.reserveCapacity(shapeOut.c + 1)
    cs = ms.reduce(into: cs) { acc, val in acc.append(contentsOf: val.cs.dropFirst().map { $0 + acc.last! }) }

    return (ri, cs, v, shapeOut)
  }

  public static func vcat<T>(_ ms: [SpMat<T>]) -> SpMat<T> where T: SwivlNumeric {
    precondition(ms.allSatisfy { $0.shape.c == ms[0].shape.c })
    let shapeOut = RowCol(ms.map { $0.shape.r }.sum(), ms[0].shape.r)

    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []

    let cumRows = ms.map { $0.shape.r }.cumsum().map(Int32.init)
    (0..<ms[0].shape.c).forEach { c in
      ms.enumerated().forEach { i, m in
        ri.append(contentsOf: m.ri[m.cs[c]..<m.cs[c+1]].map { $0 + cumRows[i] })
        v.append(contentsOf: m.v[m.cs[c]..<m.cs[c+1]])
      }
      cs.append(ri.count)
    }

    return (ri, cs, v, shapeOut)
  }
  

}
