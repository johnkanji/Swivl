//  SparseMatrix+Protocols.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import LinearAlgebra

extension SparseMatrix: CustomStringConvertible {
  public var description: String {
    let padWidth = Int(ceil(log10(Double(Swift.max(rows, cols)))))
    let matString = (0..<_values.count).map { i in
      let rc = self.valueIndexToRowColumn(i)
      let r = String(rc.r).padding(toLength: padWidth, withPad: " ", startingAt: 0)
      let c = String(rc.c).padding(toLength: padWidth, withPad: " ", startingAt: 0)
      return "\t(\(r), \(c))\t\t\(_values[i])"
    }.joined(separator: "\n")
    return "\(type(of: self)) \(shape.r)x\(shape.c)\n" + matString
  }
}


extension SparseMatrix: ExpressibleByArrayLiteral {
  public typealias ArrayLiteralElement = Self

  public init(arrayLiteral elements: Self...) {
    self.init(LinAlg.hcat(elements.map(\._spmat)))
  }
}
