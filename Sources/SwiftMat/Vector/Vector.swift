//
//  Vector.swift
//
//
//  Created by John Kanji on 2020-Jul-03.
//

import Foundation
import Accelerate

public struct Vector<T>: VectorProtocol, AccelerateMutableBuffer where T: Numeric {
  public typealias Index = Array<T>.Index
  public typealias Element = T

  var array: [Element]
  public var count: Int { array.count }

  public init() {
    array = []
  }

  public init(_ s: [T]) {
    array = s
  }

  public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
    try array.withUnsafeBufferPointer(body)
  }

  public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
    try array.withUnsafeMutableBufferPointer(body)
  }

  public subscript(position: Array<T>.Index) -> T {
    _read {
      yield array[position]
    }
  }

  public var startIndex: Index { array.startIndex }
  public var endIndex: Index { array.endIndex }

  public func index(after i: Array<T>.Index) -> Array<T>.Index {
    array.index(after: i)
  }

  public static func plus(_ lhs: Vector<T>, _ rhs: Vector<T>) -> Vector<T> {
    Self(zip(lhs.array, rhs.array).map { $0.0 + $0.1 })
  }
  public static func plus(_ lhs: T, _ rhs: Vector<T>) -> Vector<T> {
    return Self(rhs.array.map { $0 + lhs })
  }
}


extension Vector {
  public static func zeros(_ count: Int) -> Self {
    return Self([T].init(repeating: 0, count: count))
  }
  
  public func ones(_ count: Int) -> Self {
    return Self([T].init(repeating: 1, count: count))
  }
}

extension Vector: CustomStringConvertible {
  public var description: String { array.description }
}
