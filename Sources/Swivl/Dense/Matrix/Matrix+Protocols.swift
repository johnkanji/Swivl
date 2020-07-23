//  Matrix+Protocols.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension Matrix: Equatable {
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.layout == rhs.layout &&
    lhs.shape == rhs.shape &&
    lhs.flat == rhs.flat
  }
  public static func == (lhs: Self, rhs: Self) -> Bool where Scalar: SwivlFloatingPoint {
    lhs.layout == rhs.layout &&
    lhs.shape == rhs.shape &&
    zip(lhs._flat, rhs._flat).allSatisfy { $0 ==~ $1 }
  }
  
  public static func != (lhs: Self, rhs: Self) -> Bool {
    !(lhs == rhs)
  }
  
}

extension Matrix: CustomStringConvertible where Scalar: SwivlNumeric {

  private func hasFractional() -> Bool {
    if Scalar.self is Double.Type {
      return (_flat as! [Double]).anySatisfy { $0 !=~ floor($0) }
    } else if Scalar.self is Float.Type {
      return (_flat as! [Float]).anySatisfy { $0 !=~ floor($0) }
    } else {
      return false
    }
  }

  private func formatWidth() -> Int {
    if self.hasFractional() {
      return 6
    } else {
      guard let m = _flat.max() else { return 1 }
      if m < 1 { return 1 }
      let n = Self.toNSNumber(m)
      return Int(log10(Double(truncating: n))) + 2
    }
  }

  var formatter: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.usesSignificantDigits = true
    numberFormatter.maximumSignificantDigits = 4
    numberFormatter.minimumSignificantDigits = hasFractional() ? 4 : 1
    numberFormatter.formatWidth = formatWidth()
    numberFormatter.paddingPosition = .beforePrefix
    numberFormatter.paddingCharacter = " "
    return numberFormatter
  }
  
  static func toNSNumber<N>(_ value: N) -> NSNumber where N: SwivlNumeric {
    if N.self is Double.Type { return NSNumber(value: value as! Double) }
    if N.self is Float.Type { return NSNumber(value: value as! Float) }
    if N.self is Int32.Type { return NSNumber(value: value as! Int32) }
    if N.self is Int64.Type { return NSNumber(value: value as! Int64) }
    return 0
  }
  
  public var description: String {
    let formatter = self.formatter
    return "\(type(of: self)) \(shape.r)x\(shape.c)\n" +
    (0..<rows).map { r in
      "\t[ " + LinAlg.row(_mat, r).map { x in formatter.string(from: Self.toNSNumber(x))! }
        .joined(separator: ", ") +
      " ]"
    }.joined(separator: "\n")
  }
}

extension Matrix: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Self

  public init(arrayLiteral elements: Self...) {
    self.init(LinAlg.hcat(elements.map(\._mat)))
  }
}

