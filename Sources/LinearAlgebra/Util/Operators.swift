//  Operators.swift
//
//  Copyright (c) 2020 John Kanji
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0/.
//


precedencegroup EquivalencePrecedence {
  higherThan: ComparisonPrecedence
  lowerThan: AdditionPrecedence
}

infix operator ==~ : EquivalencePrecedence
infix operator !=~ : EquivalencePrecedence
infix operator <=~ : ComparisonPrecedence
infix operator >=~ : ComparisonPrecedence
infix operator <~ : ComparisonPrecedence
infix operator >~ : ComparisonPrecedence
