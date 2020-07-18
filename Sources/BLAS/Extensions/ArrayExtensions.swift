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
}
