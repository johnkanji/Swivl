//  SVD.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension LinAlg {

  //  MARK: SVD
  //  TODO: STUB
  public static func SVD<T>(_ a: Mat<T>, vectors: SingularVectorOutput = .none)
  throws -> (values: [T], leftVectors: Mat<T>?, rightVectors: Mat<T>?) where T: SwivlFloatingPoint {
    return ([], nil, nil)
  }

}

