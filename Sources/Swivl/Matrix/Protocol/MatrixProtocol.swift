//  MatrixProtocol.swift
//  
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public protocol MatrixProtocol: Collection, Equatable where Element: Numeric {
  var rows: Int { get }
  var cols: Int { get }
  
  /// Copy and transpose
  var T: Self { get }
  
  init(rows: [[Element]])
  init(columns: [[Element]])
  init(flat: [Element], shape: RowCol)
  
  subscript(row: Index, col: Index) -> Element { get set }
  
  /// Transpose in place
  mutating func transpose()
  
}

public typealias RowCol = (r: Int, c: Int)

public enum Dim {
  case row
  case col
}
