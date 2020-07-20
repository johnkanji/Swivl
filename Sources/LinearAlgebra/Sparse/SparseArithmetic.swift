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

  public static func divideElementwise<T>(_ a: SpMat<T>, _ b: SpMat<T>) -> SpMat<T> where T: SwivlFloatingPoint {
    precondition(a.shape == b.shape)

    var ri: [Int32] = []
    var cs: [Int] = [0]
    var v: [T] = []
    (0..<a.shape.c).forEach { i in
      let rngA = a.cs[i]..<a.cs[i+1]
      let rngB = b.cs[i]..<b.cs[i+1]

      assert(Set(a.ri[rngA]).subtracting(b.ri[rngB]).count == 0, "Division by zero")
      var rv = [Int32:T](uniqueKeysWithValues: zip(a.ri[rngA], a.v[rngA]))
      zip(b.ri[rngB], b.v[rngB]).forEach { i, v in
        rv[i] = rv[i, default: 0]/v
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
    var cs: [Int] = [0]
    var v: [T] = []

    for j in 0..<n {
      for i in 0..<m {
        let rngA = at.cs[i]..<at.cs[i+1]
        let rva = zip(at.ri[rngA], at.v[rngA]).sorted(by: { $0.0 < $1.0 })
        let rngB = b.cs[j]..<b.cs[j+1]
        let rvb = zip(b.ri[rngB], b.v[rngB]).sorted(by: { $0.0 < $1.0 })

        var cur_v: T = 0
        var ii = 0
        var jj = 0
        //      Step throught the current row and column finding common nonzero indices
        while ii < rva.count && jj < rvb.count {
          if rva[ii].0 == rvb[jj].0 {
            cur_v += rva[ii].1 * rvb[jj].1
          }
          //        Increment the counter "further back" in its vector
          if rva[ii].0 <= rvb[jj].0 {
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
}
