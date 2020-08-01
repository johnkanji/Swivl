//  Array+PointerAs.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public extension Array {
  
  @discardableResult
  func withUnsafeBufferPointer<T, R>(as type: T.Type, _ body: (UnsafeBufferPointer<T>) throws -> R)
  rethrows -> R {
    try self.withUnsafeBufferPointer { ptr in
      try ptr.withMemoryRebound(to: type, body)
    }
  }
  
  @discardableResult
  mutating func withUnsafeMutableBufferPointer<T, R>(
    as type: T.Type,
    _ body: (UnsafeMutableBufferPointer<T>) throws -> R
  ) rethrows -> R {
    try self.withUnsafeMutableBufferPointer { ptr in
      try ptr.withMemoryRebound(to: type, body)
    }
  }

  func anySatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
    for el in self {
      if try predicate(el) {
        return true
      }
    }
    return false
  }

}


public extension Array where Element: AdditiveArithmetic {

  func sum() -> Element {
    self.reduce(Element.zero, +)
  }

  func cumsum() -> Self {
    var out = [Element.zero]
    out.reserveCapacity(self.count + 1)
    return self.reduce(into: out) { acc, v in acc.append(acc.last! + v) }
  }

}


public extension Array where Element: Numeric {

  func prod() -> Element {
    self.reduce(1, *)
  }

}


public extension Array where Element: Collection {

  func chained() -> Array<Element.Element> {
    var out: [Element.Element] = []
    out.reserveCapacity(self.map(\.count).sum())
    return self.reduce(into: out, { acc, v in acc.append(contentsOf: v) })
  }

}


func binarySearch<R>(_ sortedArray: R, for elem: R.Element) -> Int?
where R: RandomAccessCollection, R.Index == Int, R.Element: Comparable & Equatable {
  var slice = sortedArray[...]
  while true {
    let middle = (slice.startIndex + (slice.endIndex)) / 2
    if slice.isEmpty { return nil }
    if slice.count == 1 {
      return slice.first! == elem ? slice.startIndex : nil
    }
    if elem == slice[middle] {
      return middle
    } else if elem < slice[middle] {
      slice = slice[..<middle]
    } else {
      slice = slice[middle...]
    }
  }
}
