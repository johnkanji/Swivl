//  BLAS.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

public enum BLAS {
  static let s1 = vDSP_Stride(1)
  static let rowMajor: Int32 = MatrixLayout.rowMajor.rawValue
  
  static func memoryCompatible<T, U>(_ a: T.Type, _ b: U.Type) -> Bool {
    MemoryLayout<T>.size == MemoryLayout<U>.size &&
    MemoryLayout<T>.stride == MemoryLayout<U>.stride &&
    MemoryLayout<T>.alignment == MemoryLayout<U>.alignment
  }
  
}

public typealias RowCol = (r: Int, c: Int)
public typealias SpMat<T> = (v: [T], r: [Int32], c: [Int32])
