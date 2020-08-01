//  AccelerateTypes.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

//  MARK: ApproximatelyEquatable

public protocol ApproximatelyEquatable: BinaryFloatingPoint where Stride == Self {
  static var approximateEqualityTolerance: Self { get set }
  
  static func ==~ (lhs: Self, rhs: Self) -> Bool
  static func !=~ (lhs: Self, rhs: Self) -> Bool
}

extension ApproximatelyEquatable {
  public static func ==~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs.distance(to: rhs).magnitude <= approximateEqualityTolerance
  }
  
  public static func !=~ ( lhs: Self, rhs: Self) -> Bool {
    return !( lhs ==~ rhs)
  }
}

extension Double: ApproximatelyEquatable {
  public static var approximateEqualityTolerance: Self = 1e-12
}

extension Float: ApproximatelyEquatable {
  public static var approximateEqualityTolerance: Self = 1e-12
}


//  MARK: SwivlNumeric

public protocol SwivlNumeric: SignedNumeric, Comparable {}

extension Double: SwivlNumeric {}
extension Float: SwivlNumeric {}
extension Int32: SwivlNumeric {}
extension Int: SwivlNumeric {}


//  MARK: SwivlFloatingPoint

public protocol SwivlFloatingPoint: ApproximatelyEquatable, SwivlNumeric {

  static func random(in: Range<Self>) -> Self

  static func random(in: ClosedRange<Self>) -> Self

}

extension Double: SwivlFloatingPoint {}
extension Float: SwivlFloatingPoint {}


public protocol SwivlInteger: SwivlNumeric {}

extension Int32: SwivlInteger {}
extension Int: SwivlInteger {}
