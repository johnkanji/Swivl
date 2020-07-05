//
//  File.swift
//  
//
//  Created by John Kanji on 2020-Jul-05.
//

import Foundation
import Accelerate

public typealias VectorXf = Vector<Float>

extension Vector where Element == Float {
  static public func plus(_ a: T, _ b: Self) -> Self {
    Self(vDSP.add(T(a), b))
  }
  static public func plus(_ a: Self, _ b: Self) -> Self {
    Self(vDSP.add(a, b))
  }
  
  public static func rand(_ count: Int) -> Self {
    var iDist = __CLPK_integer(1)
    var iSeed = (0..<4).map { _ in __CLPK_integer(Random.within(0.0...4095.0)) }
    var n = __CLPK_integer(count)
    var x = [Float](repeating: 0.0, count: count)
    slarnv_(&iDist, &iSeed, &n, &x)
    return Self(x)
  }

  public static func randn(_ count: Int) -> Self {
    var iDist = __CLPK_integer(3)
    var iSeed = (0..<4).map { _ in __CLPK_integer(Random.within(0.0...4095.0)) }
    var n = __CLPK_integer(count)
    var x = [Float](repeating: 0.0, count: count)
    slarnv_(&iDist, &iSeed, &n, &x)
    return Self(x)
  }
}
