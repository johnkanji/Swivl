//  RealSIMDMatrix.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

protocol RealSIMDMatrix: SIMDMatrix, RealMatrix where Scalar: SwivlFloatingPoint {}

extension RealSIMDMatrix {

  var det: Scalar {
    0
  }

  var cond: Scalar {
    0
  }

  var rank: Int {
    0
  }

  mutating func isDefinite() -> Bool {
    false
  }

  func mean() -> Scalar {
    0
  }

  func inv() -> Self {
    Self(0)
  }

  func pinv() -> Self {
    Self(0)
  }

  public static func divideElements(_ lhs: Self, _ rhs: Self) -> Self {
    precondition(lhs.shape == rhs.shape)
    return lhs / lhs
  }

  public static func divideElements(_ lhs: Self, _ rhs: Scalar) -> Self {
    lhs / Self([Scalar](repeating: rhs, count: lhs.rows*lhs.cols))
  }

  public static func / (lhs: Self, rhs: Self) -> Self {
    Self(zip(lhs.array(), rhs.array()).map { $0 / $1 })
  }

}
