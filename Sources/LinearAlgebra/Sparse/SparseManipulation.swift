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

  public static func transpose<T>(_ a: SpMat<T>) -> SpMat<T> {
    var ri: [Int32] = []
    ri.reserveCapacity(a.ri.count)
    var cs: [Int] = [0]
    var v: [T] = []
    v.reserveCapacity(a.v.count)

    let ris = Set(a.ri).sorted()
    let cis = (0..<a.cs.count-1).map { i in a.ri[a.cs[i]..<a.cs[i+1]].sorted() }

    var counter = [Int](repeating: 0, count: cis.count)
    for i in ris {
      for j in 0..<cis.count {
        while counter[j] < cis[j].count && cis[j][counter[j]] <= i {
          if cis[j][counter[j]] == i {
            ri.append(Int32(j))
            v.append(a.v[a.cs[j] + counter[j]])
          }
          counter[j] += 1
        }
      }
      cs.append(ri.count)
    }

    return (ri, cs, v, (a.shape.c, a.shape.r))
  }

}
