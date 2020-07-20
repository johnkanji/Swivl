//  RealMatrix.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

protocol RealMatrix: MatrixProtocol where Scalar: BinaryFloatingPoint {

//  MARK: Matrix Properties

  var det: Scalar { get }

  var cond: Scalar { get }

  var rank: Int { get }

  mutating func isDefinite() -> Bool


//  MARK: Unary Operators

  func mean() -> Scalar

  func inv() -> Self

  func pinv() -> Self
  
}
