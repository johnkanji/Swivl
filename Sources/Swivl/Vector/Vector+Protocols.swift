//  Vector+Protocols.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Accelerate

extension Vector: MatrixProtocol {
  public subscript(row: Index, col: Index) -> T {
    get { _layout == .rowMajor ? array[col] : array[row] }
    set {
      let i = _layout == .rowMajor ? col: row
      array[i] = newValue
    }
  }
  
  public var rows: Int { _layout == .rowMajor ? 1 : array.count }
  public var cols: Int { _layout == .rowMajor ? array.count : 1 }
  
  public var T: Vector<T> {
    switch _layout {
    case .rowMajor:
      return Self(column: array)
    default:
      return Self(row: array)
    }
  }
  
  public init(rows: [[T]]) {
    self._layout = .rowMajor
    self.array = rows.reduce([], +)
  }
  public init(columns: [[T]]) {
    self.array = columns.reduce([], +)
  }
  public init(flat: [T], shape: RowCol) {
    if shape.c == 1 {
      self.init(row: flat)
    } else {
      self.init(column: flat)
    }
  }
  
  public mutating func transpose() {
    if self._layout == .columnMajor {
      self._layout = .rowMajor
    } else {
      self._layout = .columnMajor
    }
  }
  
  public func matrix() -> Matrix<T> {
    Matrix(flat: array, shape: RowCol(rows, cols))
  }
}

extension Vector: Equatable {
  
  /// Check if two vectors are equal using approximate comparison
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs._layout == rhs._layout &&
    lhs.array == rhs.array
  }
  
  /// Check if two vectors are not equal using approximate comparison
  public static func != (lhs: Self, rhs: Self) -> Bool {
    lhs._layout != rhs._layout ||
    lhs.array != rhs.array
  }
  
}

extension Vector: CustomStringConvertible {
  public var description: String { array.description }
}

extension Vector: AccelerateMutableBuffer {
  public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
    try array.withUnsafeBufferPointer(body)
  }
  
  public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
    try array.withUnsafeMutableBufferPointer(body)
  }
}
