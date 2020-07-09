//  BLASMatrixProperties.swift
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
  
  public static func diag<T>(_ a: [T], _ shape: RowCol) -> [T] where T: AccelerateNumeric {
    let n = Swift.min(shape.r, shape.c)
    let diagi = (0..<n).map { $0*n + $0 }
    return BLAS.gather(a, diagi)
  }
  
  public static func trace<T>(_ a: [T], shape: RowCol) -> T where T: AccelerateNumeric {
    return diag(a, shape).reduce(0, *)
  }
  
  
  
}
