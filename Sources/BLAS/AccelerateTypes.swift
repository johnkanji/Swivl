//  AccelerateTypes.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol AccelerateNumeric: SignedNumeric, Comparable {}

extension Double: AccelerateNumeric {}
extension Float: AccelerateNumeric {}
extension Int32: AccelerateNumeric {}

public protocol AccelerateFloatingPoint: BinaryFloatingPoint, AccelerateNumeric where Stride == Self {}

extension Double: AccelerateFloatingPoint {}
extension Float: AccelerateFloatingPoint {}

public extension AccelerateFloatingPoint {
  
  static func ==~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs.distance(to: rhs).magnitude <= Self.leastNormalMagnitude
  }
  
  static func !=~ ( lhs: Self, rhs: Self) -> Bool {
    return !( lhs ==~ rhs)
  }
  
  static func <=~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs ==~ rhs ||  lhs <~ rhs
  }
  
  static func >=~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs ==~ rhs ||  lhs >~ rhs
  }
  
  static func <~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs.distance(to: rhs) > Self.leastNormalMagnitude
  }
  
  static func >~ ( lhs: Self, rhs: Self) -> Bool {
    return  lhs.distance(to: rhs) < -Self.leastNormalMagnitude
  }
  
}
