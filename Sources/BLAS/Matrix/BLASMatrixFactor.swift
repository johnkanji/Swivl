//  BLASMatrixFactor.swift
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

  public static func factorizeCholesky<T>(_ m: [T], _ shape: RowCol) -> (A: [T], tau: [T]) where T: AccelerateFloatingPoint {
    return ([], [])
  }

  public static func solveFactorizedCholesky<T>(_ a: [T], _ tau: [T]) -> [T] where T: AccelerateFloatingPoint {
    return []
  }


  public static func factorizeLDL<T>(_ m: [T], _ shape: RowCol) -> (A: [T], tau: [T]) where T: AccelerateFloatingPoint {
    return ([], [])
  }

  public static func solveFactorizedLDL<T>(_ a: [T], _ tau: [T]) -> [T] where T: AccelerateFloatingPoint {
    return []
  }


  public static func factorizeLU<T>(_ m: [T], _ shape: RowCol) -> (A: [T], tau: [T]) where T: AccelerateFloatingPoint {
    return ([], [])
  }

  public static func solveFactorizedLU<T>(_ a: [T], _ tau: [T]) -> [T] where T: AccelerateFloatingPoint {
    return []
  }


  public static func factorizeQR<T>(_ m: [T], _ shape: RowCol) -> (A: [T], tau: [T]) where T: AccelerateFloatingPoint {
    return ([], [])
  }

  public static func solveFactorizedQR<T>(_ a: [T], _ tau: [T]) -> [T] where T: AccelerateFloatingPoint {
    return []
  }

}
