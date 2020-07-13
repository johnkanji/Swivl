//  Matrix+Protocols.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import BLAS

extension Matrix: Equatable {
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.layout == rhs.layout &&
    lhs.shape == rhs.shape &&
    lhs.flat == rhs.flat
  }
  public static func == (lhs: Self, rhs: Self) -> Bool where Scalar: AccelerateFloatingPoint {
    lhs.layout == rhs.layout &&
    lhs.shape == rhs.shape &&
    zip(lhs._flat, rhs._flat).allSatisfy { $0 ==~ $1 }
  }
  
  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }
  
}

extension Matrix: CustomStringConvertible where Scalar: AccelerateNumeric {
  var formatter: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.usesSignificantDigits = true
    numberFormatter.formatWidth = 4
    numberFormatter.paddingPosition = .beforePrefix
    numberFormatter.paddingCharacter = " "
    return numberFormatter
  }
  
  private static func toNSNumber<N>(_ value: N) -> NSNumber where N: AccelerateNumeric {
    if N.self is Double.Type { return NSNumber(value: value as! Double) }
    if N.self is Float.Type { return NSNumber(value: value as! Float) }
    if N.self is Int32.Type { return NSNumber(value: value as! Int32) }
    if N.self is Int64.Type { return NSNumber(value: value as! Int64) }
    return 0
  }
  
  public var description: String {
    let formatter = self.formatter
    formatter.formatWidth = Int(log10(Double(truncating: Self.toNSNumber(flat.max()!)))) + 1
    return "\(type(of: self)) \(shape.r)x\(shape.c)\n" +
    (0..<rows).map { r in
      "\t[ " + BLAS.row(flat, shape, r).map { x in formatter.string(from: Self.toNSNumber(x))! }
        .joined(separator: ", ") +
      " ]"
    }.joined(separator: "\n")
  }
}

extension Matrix: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Self

  public init(arrayLiteral elements: Self...) {
    let shapes = elements.map(\.shape)
    let ms = elements.map(\.flat)
    self._flat = BLAS.hcat(ms, shapes: shapes)
    self._rows = shapes[0].r
    self._cols = shapes.map(\.c).sum()
  }
}

