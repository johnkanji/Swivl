//  SIMDMatrixTypes.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra
import simd

typealias Matrix2f = simd_float2x2
extension Matrix2f: RealSIMDMatrix {
  public typealias RowVector = simd_float2
  public typealias ColumnVector = simd_float2
  public typealias Scalar = Float
  public typealias Element = Scalar

  public static var _rows = 2
  public static var _cols = 2
}

typealias Matrix3f = simd_float3x3
extension Matrix3f: RealSIMDMatrix {
  public typealias RowVector = simd_float3
  public typealias ColumnVector = simd_float3
  public typealias Scalar = Float
  public typealias Element = Scalar

  public static var _rows = 3
  public static var _cols = 3
}

typealias Matrix4f = simd_float4x4
extension Matrix4f: RealSIMDMatrix {
  public typealias RowVector = simd_float4
  public typealias ColumnVector = simd_float4
  public typealias Scalar = Float
  public typealias Element = Scalar

  public static var _rows = 4
  public static var _cols = 4
}


typealias Matrix2d = simd_double2x2
extension Matrix2d: RealSIMDMatrix {
  public typealias RowVector = simd_double2
  public typealias ColumnVector = simd_double2
  public typealias Scalar = Double
  public typealias Element = Scalar

  public static var _rows = 2
  public static var _cols = 2
}

typealias Matrix3d = simd_double3x3
extension Matrix3d: RealSIMDMatrix {
  public typealias RowVector = simd_double3
  public typealias ColumnVector = simd_double3
  public typealias Scalar = Double
  public typealias Element = Scalar

  public static var _rows = 3
  public static var _cols = 3
}

typealias Matrix4d = simd_double4x4
extension Matrix4d: RealSIMDMatrix {
  public typealias RowVector = simd_double4
  public typealias ColumnVector = simd_double4
  public typealias Scalar = Double
  public typealias Element = Scalar

  public static var _rows = 4
  public static var _cols = 4
}
