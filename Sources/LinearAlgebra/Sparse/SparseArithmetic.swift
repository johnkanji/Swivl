//  SparseArithmetic.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

  public static func add<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlNumeric {
    precondition(a.shape == b.shape)

    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []
    (0..<a.shape.c).forEach { i in
      let rngA = a.cs[i]..<a.cs[i+1]
      let rngB = b.cs[i]..<b.cs[i+1]

      let x = zip(a.ri[rngA] + b.ri[rngB], a.v[rngA] + b.v[rngB])
      let rv = [Int32:T](x, uniquingKeysWith: +).sorted(by: { $0.key < $1.key })
      ri.append(contentsOf: rv.map(\.key))
      v.append(contentsOf: rv.map(\.value))
      cs.append(cs.last! + rv.count)
    }
    return SpMat(ri, cs, v, a.shape)
  }

  public static func subtract<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlNumeric {
    var b = b
    (0..<b.v.count).forEach { i in b.v[i] = -b.v[i] }
    return add(a, b)
  }

  public static func multiplyElementwise<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlNumeric {
    precondition(a.shape == b.shape)

    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []
    (0..<a.shape.c).forEach { i in
      let riA = a.ri[a.cs[i]..<a.cs[i+1]]
      let riB = b.ri[b.cs[i]..<b.cs[i+1]]

      let curr_ri = Set<Int32>(riA).intersection(riB).sorted()
      ri.append(contentsOf: curr_ri)
      v.append(contentsOf: curr_ri.map { i in a.v[riA.firstIndex(of: i)!] * b.v[riB.firstIndex(of: i)!] })
      cs.append(cs.last! + curr_ri.count)
    }
    return (ri, cs, v, a.shape)
  }

  public static func divideElementwise<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlNumeric {
    precondition(a.shape == b.shape)

    func div(_ lhs: T, _ rhs: T) -> T {
      if T.self is Double.Type {
        return ((lhs as! Double) / (rhs as! Double)) as! T
      } else if T.self is Float.Type {
        return ((lhs as! Float) / (rhs as! Float)) as! T
      } else {
        return ((lhs as! Int32) / (rhs as! Int32)) as! T
      }
    }

    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []
    (0..<a.shape.c).forEach { i in
      let rngA = a.cs[i]..<a.cs[i+1]
      let rngB = b.cs[i]..<b.cs[i+1]

      assert(Set(a.ri[rngA]).subtracting(b.ri[rngB]).count == 0, "Division by zero")
      var rv = [Int32:T](uniqueKeysWithValues: zip(a.ri[rngA], a.v[rngA]))
      zip(b.ri[rngB], b.v[rngB]).forEach { i, v in
        rv[i] = div(rv[i, default: 0], v)
      }
      ri.append(contentsOf: rv.map(\.key))
      v.append(contentsOf: rv.map(\.value))
      cs.append(cs.last! + rv.count)
    }
    return (ri, cs, v, a.shape)
  }


  public static func multiplyMatrix<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlNumeric {
    precondition(a.shape.c == b.shape.r)
    let at = transpose(a)

    let m = a.shape.r
    let n = b.shape.c

    var ri: [Int32] = []
    ri.reserveCapacity(Swift.max(a.ri.count, b.ri.count))
    var cs: [Int] = [0]
    cs.reserveCapacity(b.shape.c + 1)
    var v: [T] = []
    v.reserveCapacity(Swift.max(a.v.count, b.v.count))

    for j in 0..<n {
      for i in 0..<m {
        let rngA = at.cs[i]..<at.cs[i+1]
        let rngB = b.cs[j]..<b.cs[j+1]

        let ria = at.ri[rngA]
        let rib = b.ri[rngB]

        var cur_v: T = 0
        var ii = 0
        var jj = 0
        //  Step throught the current row and column finding common nonzero indices
        while ii < ria.count && jj < rib.count {
          if ria[ria.startIndex + ii] == rib[rib.startIndex + jj] {
            cur_v += at.v[ria.startIndex + ii] * b.v[rib.startIndex + jj]
          }
          //  Increment the counter "further back" in its vector
          if ria[ria.startIndex + ii] <= rib[rib.startIndex + jj] {
            ii += 1
          } else {
            jj += 1
          }
        }
        if cur_v != 0 {
          ri.append(Int32(i))
          v.append(cur_v)
        }
      }
      cs.append(ri.count)
    }
    return SpMat<T>(ri, cs, v, (m,n))
  }


  public static func multiplyMatrixVector<T>(_ a: SpMat<T>, _ b: [T]) -> [T] where T: SwivlNumeric {
    precondition(a.shape.c == b.count)

    var y = [T](repeating: 0, count: a.shape.r)
    for r in 0..<a.shape.r {
      for c in 0..<a.shape.c {
        let ris = a.ri[a.cs[c]..<a.cs[c+1]]
        if let ii = binarySearch(ris, for: Int32(r)) {
          y[r] += b[c]*a.v[ii]
        }
      }
    }
    return y
  }

}
