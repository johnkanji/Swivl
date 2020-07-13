//  MatrixConcatenatable.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol MatrixConcatenatable: ExpressibleByArrayLiteral {

  static func hcat(_ matrices: Self...) -> Self

  static func vcat(_ matrices: Self...) -> Self

}


extension MatrixConcatenatable {

  static func || (_ lhs: Self, _ rhs: Self) -> Self {
    vcat(lhs, rhs)
  }

}
