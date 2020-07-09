//  BLASMatrixArithmetic.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension BLAS {
  
  public static func multiplyMatrix<T>(_ a: [T], _ shapeA: RowCol, _ b: [T], _ shapeB: RowCol) -> ([T], RowCol)
  where T: AccelerateFloatingPoint {
    precondition(shapeA.c == shapeB.r)
    let m = vDSP_Length(shapeA.r)
    let n = vDSP_Length(shapeB.c)
    let p = vDSP_Length(shapeA.c)
    if T.self is Double.Type {
      var c = [Double](repeating: 0, count: Int(m*n))
      vDSP_mmulD(a as! [Double], s1, b as! [Double], s1, &c, s1, m, n, p)
      return (c as! [T], (Int(m), Int(n)))
    } else {
      var c = [Float](repeating: 0, count: Int(m*n))
      vDSP_mmul(a as! [Float], s1, b as! [Float], s1, &c, s1, m, n, p)
      return (c as! [T], (Int(m), Int(n)))
    }
  }

}
