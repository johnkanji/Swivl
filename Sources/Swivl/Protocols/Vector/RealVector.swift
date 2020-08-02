//  RealVector.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

public protocol RealVector: VectorProtocol where Scalar: SwivlFloatingPoint {

//  MARK: Unary Operators

  func mean() -> Scalar

  //  MARK: Geometric Operations

  var length: Scalar { get }

  static func normalize(_ v: Self) -> Self

  static func project(_ a: Self, onto b: Self) -> Self

  static func dist(_ a: Self, _ b: Self) -> Scalar


//  MARK: Vector Creation

  static func linear(_ start: Scalar, _ stop: Scalar, _ count: Int) -> Self

  static func rand(_ count: Int) -> Self

  static func randn(_ count: Int) -> Self
  
}


//  MARK: Default Implementations

extension RealVector {

//  MARK: Geometric Operations

  public var norm: Scalar { self.length }

  public var normalized: Self { Self.normalize(self) }

  public func dist(to v: Self) -> Scalar { Self.dist(self, v) }

  public func project(onto v: Self) -> Self { Self.project(self, onto: v) }


}
