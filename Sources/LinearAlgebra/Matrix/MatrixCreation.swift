//  MatrixCreation.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension LinAlg {
  
  public static func eye<T>(_ n: Int) -> Mat<T> where T: SwivlNumeric {
    var I = [T](repeating: 0, count: n*n)
    (0..<n).forEach { I[$0*n + $0] = 1 }
    return (I, (n,n))
  }
  
}
