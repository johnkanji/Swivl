//  SIMDVector.swift
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

extension SIMD2: VectorProtocol, Collection, Sequence where Scalar: AccelerateFloatingPoint {
  public typealias T = Scalar

  public func abs() -> Self { Self(self.map { Swift.abs($0) }) }
  public func abs() -> Self where T == Double { simd_abs(self) }
  public func abs() -> Self where T == Float { simd_abs(self) }

//  MARK: Manipulation

  public func diag<M>() -> M where M : MatrixProtocol, Self.Element == M.Element {
    M([])
  }


  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    if Scalar.self is Double.Type {
      return simd_dot(lhs as! SIMD2<Double>, rhs as! SIMD2<Double>) as! Scalar
    } else {
      return simd_dot(lhs as! SIMD2<Float>, rhs as! SIMD2<Float>) as! Scalar
    }
  }

}

extension SIMD3: VectorProtocol, Collection, Sequence where Scalar: AccelerateFloatingPoint {
  public typealias T = Scalar

  public func abs() -> Self { Self(self.map { Swift.abs($0) }) }
  public func abs() -> Self where T == Double { simd_abs(self) }
  public func abs() -> Self where T == Float { simd_abs(self) }

  //  MARK: Manipulation

  public func diag<M>() -> M where M : MatrixProtocol, Self.Element == M.Element {
    M([])
  }


  public static func dot(_ lhs: Self, _ rhs: Self) -> Scalar {
    if Scalar.self is Double.Type {
      return simd_dot(lhs as! SIMD3<Double>, rhs as! SIMD3<Double>) as! Scalar
    } else {
      return simd_dot(lhs as! SIMD3<Float>, rhs as! SIMD3<Float>) as! Scalar
    }
  }

}


//extension simd_float3x3: MatrixProtocol {
//  public var rows: Int { 3 }
//  public var cols: Int { 3 }
//
//  public var shape: RowCol { RowCol(3,3) }
//
//  public var isSymmetric: Bool { self == self.transpose }
//
//  public var isLowerTringular: Bool {
//    self[0,1] ==~ 0 && self[0,2] == 0 && self[1,2] == 0
//  }
//
//  public var isUpperTriangular: Bool {
//    self[1,0] ==~ 0 && self[2,0] == 0 && self[2,1] == 0
//  }
//
//  public var isDiagonal: Bool {
//    self == Self(diagonal: simd_float3(self[0,0], self[1,1], self[2,2]))
//  }
//
//  public var trace: Float {
//    let v: SIMD3<Float> = self.diag()
//    .square().sum()
//  }
//
//  public var norm: T {
//    <#code#>
//  }
//
//  public init(rows: [[SIMD3<Float>]]) {
//    <#code#>
//  }
//
//  public init(_ rows: [[SIMD3<Float>]]) {
//    <#code#>
//  }
//
//  public init(columns: [[SIMD3<Float>]]) {
//    <#code#>
//  }
//
//  public init(flat: [SIMD3<Float>], shape: RowCol) {
//    <#code#>
//  }
//
//  public subscript(row: Int, column: Int) -> T {
//    get {
//      <#code#>
//    }
//    set {
//      <#code#>
//    }
//  }
//
//  public func rowColumnToFlatIndex(_ i: RowCol) -> Int {
//    <#code#>
//  }
//
//  public func flatIndexToRowColumn(_ i: Int) -> RowCol {
//    <#code#>
//  }
//
//  public var T: simd_float3x3 {
//    <#code#>
//  }
//
//  public static func † (a: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public mutating func transpose() {
//    <#code#>
//  }
//
//  public static func hcat(_ matrices: simd_float3x3...) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func vcat(_ matrices: simd_float3x3...) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public func diag<V>() -> V where V : VectorProtocol, V.Element == Float {
//    V([self[0,0], self[1,1], self[2,2]])
//  }
//
//  public func tri(_ triangle: TriangularType, diagonal: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func negate(_ lhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public func abs() -> simd_float3x3 {
//    <#code#>
//  }
//
//  public func max() -> (T, RowCol)? {
//    <#code#>
//  }
//
//  public func min() -> (T, RowCol)? {
//    <#code#>
//  }
//
//  public func sum() -> T {
//    <#code#>
//  }
//
//  public func square() -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func add(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func add(_ lhs: simd_float3x3, _ rhs: SIMD3<Float>) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func subtract(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func subtract(_ lhs: simd_float3x3, _ rhs: SIMD3<Float>) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func multiplyElements(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func multiplyElements(_ lhs: simd_float3x3, _ rhs: SIMD3<Float>) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func divideElements(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func divideElements(_ lhs: simd_float3x3, _ rhs: SIMD3<Float>) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func multiplyMatrix(_ lhs: simd_float3x3, _ rhs: simd_float3x3) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func zeros(_ rows: Int, _ cols: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func ones(_ rows: Int, _ cols: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func rand(_ rows: Int, _ cols: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func randn(_ rows: Int, _ cols: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public static func eye(_ n: Int) -> simd_float3x3 {
//    <#code#>
//  }
//
//  public func vector<V>() -> V where V : VectorProtocol, Self.Element == V.Element {
//    <#code#>
//  }
//
//  public var startIndex: Int {
//    <#code#>
//  }
//
//  public var endIndex: Int {
//    <#code#>
//  }
//
//
//}
