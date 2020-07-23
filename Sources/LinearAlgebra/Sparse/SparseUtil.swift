//  SparseUtil.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {

  public static func valueIndexToRowCol<T>(_ a: SpMat<T>, _ vi: Int) -> RowCol where T: SwivlNumeric {
    let r = Int(a.ri[vi])
    let c = a.cs.lastIndex(where: { c in c <= vi }) ?? 0
    return (r, c)
  }

  public static func valueIndexToFlatIndex<T>(_ a: SpMat<T>, _ vi: Int) -> Int where T: SwivlNumeric {
    let (r, c) = valueIndexToRowCol(a, vi)
    return r * a.shape.c + c
  }

  public static func rowColToValueIndex<T>(_ a: SpMat<T>, _ i: RowCol) -> Int? where T: SwivlNumeric {
    let ris = a.ri[a.cs[i.c]..<a.cs[i.c + 1]]
    guard let vi = ris.firstIndex(where: { $0 == Int32(i.r) }) else { return nil }
    return vi
  }

}
