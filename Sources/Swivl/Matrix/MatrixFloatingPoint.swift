//  MatrixFloatingPoint.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Matrix where T: AccelerateFloatingPoint {
  
  public var det: T {
    BLAS.det(_flat, shape)
  }
  
  public var isDefinite: Bool {
    return (try? self.chol()) != nil
  }
  
}
