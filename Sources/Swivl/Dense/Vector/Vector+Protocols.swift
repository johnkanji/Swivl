//  Vector+Protocols.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Vector {
  public subscript(row: Index, col: Index) -> Scalar {
    get { layout == .rowMajor ? array[col] : array[row] }
    set {
      let i = layout == .rowMajor ? col: row
      array[i] = newValue
    }
  }
  
  public var rows: Int { layout == .rowMajor ? 1 : array.count }
  public var cols: Int { layout == .rowMajor ? array.count : 1 }
  public var shape: RowCol { (rows, cols) }
  
  public var T: Self {
    switch layout {
    case .rowMajor:
      return Self(column: array)
    default:
      return Self(row: array)
    }
  }

  public static postfix func †(_ a: Self) -> Self {
    a.T
  }
  
  public mutating func transpose() {
    if self.layout == .columnMajor {
      self.layout = .rowMajor
    } else {
      self.layout = .columnMajor
    }
  }
}


extension Vector: Equatable {

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.layout == rhs.layout &&
    lhs.count == rhs.count &&
    lhs.array == rhs.array
  }
  public static func == (lhs: Self, rhs: Self) -> Bool where Scalar: ApproximatelyEquatable {
    lhs.layout == rhs.layout &&
    lhs.count == rhs.count &&
    zip(lhs.array, rhs.array).allSatisfy { $0 ==~ $1 }
  }

  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }

}


extension Vector: CustomStringConvertible {
  public var description: String { array.description }
}


extension Vector: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Scalar

  public init(arrayLiteral elements: Scalar...) {
    self.array = elements
  }
}


// Useful array wrappers
extension Vector {

  public func lastIndex(of: Scalar) -> Index? {
    array.lastIndex(of: of)
  }

  public func lastIndex(where cond: (Scalar) throws -> Bool) rethrows -> Int? {
    try array.lastIndex(where: cond)
  }

  public func last(where cond: (Scalar) throws -> Bool) rethrows -> Scalar? {
    try array.last(where: cond)
  }

}
