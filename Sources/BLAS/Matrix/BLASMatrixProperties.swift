//  BLASMatrixProperties.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension BLAS {
  
  public static func diag<T>(_ a: [T], _ shape: RowCol) -> [T] where T: AccelerateNumeric {
    let n = Swift.min(shape.r, shape.c)
    let diagi = (0..<n).map { $0*n + $0 }
    return BLAS.gather(a, diagi)
  }

  public static func diag<T>(_ a: [T]) -> [T] where T: AccelerateNumeric {
    let n = a.count
    var out = [T](repeating: 0, count: n*n)
    (0..<n).forEach { i in
      out[i*n+i] = a[i]
    }
    return out
  }
  
  public static func trace<T>(_ a: [T], _ shape: RowCol) -> T where T: AccelerateNumeric {
    return diag(a, shape).reduce(0, *)
  }
  
  public static func det<T>(_ a: [T], _ shape: RowCol) -> T where T: AccelerateFloatingPoint {
    precondition(shape.r == shape.c, "Only square matrices are supported")
    
    func detPerm(_ p: [T]) -> T {
      let diagp = diag(p, shape)
      let swaps = shape.r - Int(diagp.reduce(0, +));
      return swaps % 2 == 0 ? 1 : -1
    }
    
    let (_, (U, _) ,P, Q) = BLAS.LU(a, shape, output: .LUPQ)
    return detPerm(P!) * detPerm(Q!) * diag(U, shape).reduce(1, *)
  }
  
}
