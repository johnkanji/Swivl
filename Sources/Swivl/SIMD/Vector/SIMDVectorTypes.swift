//  SIMDVectorTypes.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS
import simd

//  MARK: - Vector2

extension SIMD2 where Scalar: AccelerateFloatingPoint {
  public typealias Element = Scalar

  public func abs() -> Self where Scalar == Double { simd_abs(self) }
  public func abs() -> Self where Scalar == Float { simd_abs(self) }

  public func normalize(_ v: Self) -> Self where Scalar == Double { simd_normalize(self) }
  public func normalize(_ v: Self) -> Self where Scalar == Float { simd_normalize(self) }

  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_dot(a, b) }
  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_dot(a, b) }

  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Double { simd_project(a, b) }
  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Float { simd_project(a, b) }

  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_distance(a, b) }
  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_distance(a, b) }

  func _length() -> Scalar where Scalar == Double { simd_length(self) }
  func _length() -> Scalar where Scalar == Float { simd_length(self) }

}

extension SIMD2: VectorProtocol, Collection, Sequence where Scalar: AccelerateFloatingPoint {}

public typealias Vector2d = SIMD2<Double>
public typealias Vector2f = SIMD2<Float>


//  MARK: - Vector3

extension SIMD3 where Scalar: AccelerateFloatingPoint {
  public typealias Element = Scalar

  public func abs() -> Self where Scalar == Double { simd_abs(self) }
  public func abs() -> Self where Scalar == Float { simd_abs(self) }

  public func normalize(_ v: Self) -> Self where Scalar == Double { simd_normalize(self) }
  public func normalize(_ v: Self) -> Self where Scalar == Float { simd_normalize(self) }

  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_dot(a, b) }
  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_dot(a, b) }

  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Double { simd_project(a, b) }
  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Float { simd_project(a, b) }

  public static func cross(_ a: Self, _ b: Self) -> Self where Scalar == Double { simd_cross(a, b) }
  public static func cross(_ a: Self, _ b: Self) -> Self where Scalar == Float { simd_cross(a, b) }

  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_distance(a, b) }
  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_distance(a, b) }

  func _length() -> Scalar where Scalar == Double { simd_length(self) }
  func _length() -> Scalar where Scalar == Float { simd_length(self) }

}

extension SIMD3: VectorProtocol, Collection, Sequence where Scalar: AccelerateFloatingPoint {}

public typealias Vector3d = SIMD3<Double>
public typealias Vector3f = SIMD3<Float>


//  MARK: - Vector4

extension SIMD4 where Scalar: AccelerateFloatingPoint {
  public typealias Element = Scalar

  public func abs() -> Self where Scalar == Double { simd_abs(self) }
  public func abs() -> Self where Scalar == Float { simd_abs(self) }

  public func normalize(_ v: Self) -> Self where Scalar == Double { simd_normalize(self) }
  public func normalize(_ v: Self) -> Self where Scalar == Float { simd_normalize(self) }

  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_dot(a, b) }
  public static func dot(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_dot(a, b) }

  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Double { simd_project(a, b) }
  public static func project(_ a: Self, onto b: Self) -> Self where Scalar == Float { simd_project(a, b) }

  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Double { simd_distance(a, b) }
  public static func dist(_ a: Self, _ b: Self) -> Scalar where Scalar == Float { simd_distance(a, b) }

  func _length() -> Scalar where Scalar == Double { simd_length(self) }
  func _length() -> Scalar where Scalar == Float { simd_length(self) }

}

extension SIMD4: VectorProtocol, Collection, Sequence where Scalar: AccelerateFloatingPoint {}

public typealias Vector4d = SIMD4<Double>
public typealias Vector4f = SIMD4<Float>
