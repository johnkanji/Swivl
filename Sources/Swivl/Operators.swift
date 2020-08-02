//  Operators.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

precedencegroup ExponetiationPrecedence {
  higherThan: MultiplicationPrecedence
}

infix operator .* : MultiplicationPrecedence
infix operator ./ : MultiplicationPrecedence
infix operator .^ : ExponetiationPrecedence

prefix operator √

postfix operator †
